import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/tracked_web_launcher_service.dart';
import '../../../core/state/app_state.dart';

class ScratchCardScreen extends ConsumerStatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  ConsumerState<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends ConsumerState<ScratchCardScreen> {
  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  static const List<int> _rewards = [0, 10, 20, 30, 50, 80, 100, 120];
  final _rng = Random();

  bool _enabled = false;
  bool _resultShown = false;
  int _reward = 0;

  void _start() {
    if (_enabled) return;
    setState(() {
      _enabled = true;
      _reward = _rewards[_rng.nextInt(_rewards.length)];
    });
  }

  Future<void> _showRewardDialog() async {
    if (_resultShown) return;
    _resultShown = true;

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
                  'SCRATCH RESULT',
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
                  'You won $_reward points',
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
                      if (_reward > 0) {
                        await ref.read(balanceProvider.notifier).add(_reward);
                      }
                      try {
                        await TrackedWebLauncherService.instance.openAndWait(
                          closeUrl,
                          label: 'Scratch card',
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0B0700),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2A200F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Scratch To Win'),
          foregroundColor: const Color(0xCCFFFFFF),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: _background),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                children: [
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      color: const Color(0xFFE2A321),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'You have won',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF2A200F,
                                    ).withOpacity(0.85),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$_reward points',
                                  style: const TextStyle(
                                    color: Color(0xFF2A200F),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ScratchOverlay(
                            enabled: _enabled,
                            onFirstScratch: _start,
                            onProgress: (p) async {
                              if (!mounted) return;
                              if (_resultShown) return;
                              if (p >= 0.5) await _showRewardDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
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
                      onPressed: _enabled ? null : _start,
                      child: const Text(
                        'SCRATCH NOW',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScratchOverlay extends StatefulWidget {
  const _ScratchOverlay({
    required this.enabled,
    required this.onFirstScratch,
    required this.onProgress,
  });

  final bool enabled;
  final VoidCallback onFirstScratch;
  final ValueChanged<double> onProgress;

  @override
  State<_ScratchOverlay> createState() => _ScratchOverlayState();
}

class _ScratchOverlayState extends State<_ScratchOverlay> {
  static const int _grid = 40;
  static const double _scratchRadius = 24;
  static const double _minPointDistance = 3;

  final Path _path = Path();
  final ValueNotifier<int> _repaintTick = ValueNotifier<int>(0);
  Offset? _lastPoint;

  final List<bool> _covered = List<bool>.filled(_grid * _grid, false);
  int _coveredCount = 0;
  Size _size = Size.zero;

  ui.Image? _overlayImage;

  @override
  void initState() {
    super.initState();
    _loadOverlay();
  }

  @override
  void dispose() {
    _repaintTick.dispose();
    super.dispose();
  }

  Future<void> _loadOverlay() async {
    final data = await rootBundle.load('assets/scratch.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _overlayImage = frame.image);
  }

  void _addPoint(Offset localPosition) {
    final last = _lastPoint;
    if (last == null) {
      _path.moveTo(localPosition.dx, localPosition.dy);
      _lastPoint = localPosition;
      _markCoverage(localPosition);
    } else {
      final dx = localPosition.dx - last.dx;
      final dy = localPosition.dy - last.dy;
      if ((dx * dx + dy * dy) < (_minPointDistance * _minPointDistance)) {
        return;
      }
      _path.lineTo(localPosition.dx, localPosition.dy);
      _lastPoint = localPosition;
      _markCoverageSegment(last, localPosition);
    }

    final progress = _coveredCount / (_grid * _grid);
    widget.onProgress(progress);
    _repaintTick.value++;
  }

  void _markCoverageSegment(Offset from, Offset to) {
    final distance = (to - from).distance;
    if (distance <= 0) return;
    final step = max(2.0, _scratchRadius * 0.55);
    final steps = max(1, (distance / step).ceil());
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final p = Offset.lerp(from, to, t);
      if (p == null) continue;
      _markCoverage(p);
    }
  }

  void _markCoverage(Offset p) {
    if (_size == Size.zero) return;
    final cx = (p.dx / _size.width * _grid).floor();
    final cy = (p.dy / _size.height * _grid).floor();
    final rCells = max(1, (_scratchRadius / _size.shortestSide * _grid).ceil());

    for (var dy = -rCells; dy <= rCells; dy++) {
      for (var dx = -rCells; dx <= rCells; dx++) {
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 || x >= _grid || y < 0 || y >= _grid) continue;
        if (dx * dx + dy * dy > rCells * rCells) continue;
        final idx = y * _grid + x;
        if (_covered[idx]) continue;
        _covered[idx] = true;
        _coveredCount++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final img = _overlayImage;
        if (img == null) {
          return Image.asset('assets/scratch.png', fit: BoxFit.cover);
        }

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              if (!widget.enabled) widget.onFirstScratch();
              _addPoint(d.localPosition);
            },
            onPanUpdate: (d) {
              if (!widget.enabled) widget.onFirstScratch();
              _addPoint(d.localPosition);
            },
            child: CustomPaint(
              painter: _ScratchPainter(
                image: img,
                path: _path,
                radius: _scratchRadius,
                repaint: _repaintTick,
              ),
              isComplex: true,
              willChange: true,
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

class _ScratchPainter extends CustomPainter {
  _ScratchPainter({
    required this.image,
    required this.path,
    required this.radius,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final ui.Image image;
  final Path path;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(image, src, rect, Paint());

    final clear = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, clear);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.radius != radius ||
        oldDelegate.path != path;
  }
}
