import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/tracked_web_launcher_service.dart';
import '../../../core/state/app_state.dart';

class SpinToWinScreen extends ConsumerStatefulWidget {
  const SpinToWinScreen({super.key});

  @override
  ConsumerState<SpinToWinScreen> createState() => _SpinToWinScreenState();
}

class _SpinToWinScreenState extends ConsumerState<SpinToWinScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

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

    if (reward > 0) await ref.read(balanceProvider.notifier).add(reward);

    if (!mounted) return;
    await _showResultDialog(reward);
  }

  Future<void> _showResultDialog(int reward) async {
    final rootContext = context;
    final remoteUrls = ref.read(remoteUrlsProvider).valueOrNull;
    final closeUrl = remoteUrls?.splash ?? AppUrls.welcome;
    await showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SPIN RESULT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 16,
                    color: Color(0xFF2A200F),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'You won $reward points',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2A200F),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7D39A),
                      foregroundColor: const Color(0xFF2A200F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      try {
                        await TrackedWebLauncherService.instance.openAndWait(
                          closeUrl,
                          label: 'Spin to win',
                        );
                      } catch (_) {}
                      if (!rootContext.mounted) return;
                      rootContext.go('/');
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF0B0700),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF2A200F),
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
          body: Container(
            decoration: const BoxDecoration(gradient: _background),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7D39A),
                          foregroundColor: const Color(0xFF2A200F),
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
  const _Wheel({required this.rotation, required this.segments});

  final double rotation;
  final List<int> segments;

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
              Image.asset(
                'assets/center.png',
                width: radius * 0.22,
                height: radius * 0.22,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
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
                width: 18,
                height: 18,
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
