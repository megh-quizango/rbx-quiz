import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/custom_tab_service.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlay_shimmer.dart';
import '../../../core/widgets/winner_reward_dialog.dart';

class SpinToWinScreen extends ConsumerStatefulWidget {
  const SpinToWinScreen({super.key});

  @override
  ConsumerState<SpinToWinScreen> createState() => _SpinToWinScreenState();
}

class _SpinToWinScreenState extends ConsumerState<SpinToWinScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const List<int> _segments = [100, 30, 10, 0, 50, 20, 80, 120];

  late final AnimationController _controller;
  Animation<double>? _spinAnimation;

  final _random = Random();

  double _rotation = 0;
  double _spinStartRotation = 0;
  bool _isSpinning = false;
  int _pendingReward = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishSpinIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cancelSpin();
    }
  }

  Future<void> _startSpin() async {
    if (_isSpinning) return;

    final targetIndex = _random.nextInt(_segments.length);
    final end = _computeEndRotation(targetIndex);

    setState(() {
      _isSpinning = true;
      _spinStartRotation = _rotation;
      _pendingReward = _segments[targetIndex];
      _spinAnimation = Tween<double>(begin: _rotation, end: end).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
    });

    _controller.forward(from: 0);
  }

  void _cancelSpin() {
    if (!_isSpinning) return;
    _controller.stop();
    setState(() {
      _isSpinning = false;
      _spinAnimation = null;
      _pendingReward = 0;
      _rotation = _spinStartRotation;
    });
  }

  Future<void> _finishSpinIfNeeded() async {
    if (!_isSpinning) return;
    _rotation = _spinAnimation?.value ?? _rotation;
    setState(() {
      _isSpinning = false;
      _spinAnimation = null;
    });

    final reward = _pendingReward;
    _pendingReward = 0;

    if (!mounted) return;
    await _showResultDialog(reward);
  }

  Future<void> _showResultDialog(int reward) async {
    final rootContext = context;
    await showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: WinnerRewardDialog(
            reward: reward,
            onClaim: () async {
              Navigator.of(context).pop();
              SplashTabsConfig config;
              try {
                config = await ref.read(splashTabsConfigProvider.future);
              } catch (_) {
                config = SplashTabsConfig.fallback;
              }
              if (config.enabled) {
                String url;
                try {
                  url = await ref.read(welcomeUrlProvider.future);
                } catch (_) {
                  final remote = ref.read(remoteUrlsProvider).valueOrNull;
                  url = remote?.splash ?? AppUrls.welcome;
                }
                try {
                  await CustomTabService.open(url);
                } catch (_) {}
              }
              if (reward > 0) {
                await ref.read(balanceProvider.notifier).add(reward);
              }
              if (!rootContext.mounted) return;
              rootContext.go('/');
            },
          ),
        );
      },
    );
  }

  double _computeEndRotation(int targetIndex) {
    final segmentAngle = 2 * pi / _segments.length;
    final target = _normalizeAngle(-targetIndex * segmentAngle);
    final current = _normalizeAngle(_rotation);
    final delta = _posMod(target - current, 2 * pi);
    final fullSpins = (6 + _random.nextInt(3)) * 2 * pi;
    return _rotation + fullSpins + delta;
  }

  static double _posMod(double x, double m) => (x % m + m) % m;
  static double _normalizeAngle(double a) => _posMod(a, 2 * pi);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSpinning) {
          _cancelSpin();
          return false;
        }
        await SplashTabsLauncherService.openForTrigger(
          context,
          trigger: 'back',
        );
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFFF6EFE2),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF241802),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_isSpinning) {
                  _cancelSpin();
                  return;
                }
                Navigator.of(context).maybePop();
              },
            ),
            title: const Text('Spin To Win'),
            foregroundColor: const Color(0xCCFFFFFF),
          ),
          backgroundColor: const Color(0xFFF6EFE2),
          body: Container(
            color: const Color(0xFFF6EFE2),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Spin Now & Win Points',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2A200F),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final rotation = _spinAnimation?.value ?? _rotation;
                          return RepaintBoundary(
                            child: _Wheel(
                              rotation: rotation,
                              segments: _segments,
                              onCenterTap: _isSpinning ? null : _startSpin,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: OverlayShimmer(
                      borderRadius: BorderRadius.circular(14),
                      opacity: 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0AA14),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFFE0AA14,
                            ).withOpacity(0.65),
                            disabledForegroundColor: Colors.white.withOpacity(
                              0.85,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSpinning ? null : _startSpin,
                          child: const Text(
                            'SPIN NOW',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.rotation,
    required this.segments,
    required this.onCenterTap,
  });

  final double rotation;
  final List<int> segments;
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight) * 0.92;
        final radius = size / 2;
        final segmentAngle = 2 * pi / segments.length;
        final labelRadius = radius * 0.60;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size, size),
                      painter: _WheelPainter(segments.length),
                    ),
                    for (var i = 0; i < segments.length; i++)
                      _WheelLabel(
                        value: segments[i],
                        angle: (-pi / 2) + i * segmentAngle,
                        radius: labelRadius,
                      ),
                  ],
                ),
              ),
              Positioned(
                top: -radius * 0.12,
                child: Image.asset(
                  'assets/pointer.png',
                  width: radius * 0.26,
                  height: radius * 0.26,
                  fit: BoxFit.contain,
                ),
              ),
              _SpinCenterButton(size: radius * 0.34, onTap: onCenterTap),
            ],
          ),
        );
      },
    );
  }
}

class _SpinCenterButton extends StatelessWidget {
  const _SpinCenterButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size * 1.5,
          height: size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/bg.png',
                width: size * 1.5,
                height: size * 1.5,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              Image.asset(
                'assets/bg_border.png',
                width: size * 1.3,
                height: size * 1.3,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              Image.asset(
                'assets/spin_text.png',
                width: size * 0.76,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelLabel extends StatelessWidget {
  const _WheelLabel({
    required this.value,
    required this.angle,
    required this.radius,
  });

  final int value;
  final double angle;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final offset = Offset(cos(angle) * radius, sin(angle) * radius);

    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: angle + pi / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  color: Color(0xFF2A200F),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Image.asset(
                'assets/currency.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.segmentCount);

  final int segmentCount;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segmentCount;
    final startAngle = (-pi / 2) - (segmentAngle / 2);

    final wedgePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < segmentCount; i++) {
      wedgePaint.color = (i.isEven) ? Colors.white : const Color(0xFFE7D39A);
      canvas.drawArc(
        rect,
        startAngle + i * segmentAngle,
        segmentAngle,
        true,
        wedgePaint,
      );
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..color = const Color(0xFFE2A321);
    canvas.drawCircle(center, radius - ringPaint.strokeWidth / 2, ringPaint);

    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.008
      ..color = const Color(0x552A200F);
    canvas.drawCircle(center, radius * 0.92, innerRing);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount;
  }
}
