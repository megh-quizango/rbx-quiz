import 'package:flutter/material.dart';

class OverlayShimmer extends StatefulWidget {
  const OverlayShimmer({
    super.key,
    required this.child,
    required this.borderRadius,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1800),
    this.opacity = 0.18,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool enabled;
  final Duration duration;
  final double opacity;

  @override
  State<OverlayShimmer> createState() => _OverlayShimmerState();
}

class _OverlayShimmerState extends State<OverlayShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(OverlayShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (!widget.enabled) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 0;
    } else {
      if (!_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          if (widget.enabled)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    final start = -2.0 + (4.0 * t);
                    final end = start + 2.0;

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(start, start),
                          end: Alignment(end, end),
                          colors: [
                            Colors.white.withOpacity(0.03),
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(widget.opacity * 0.4),
                            Colors.white.withOpacity(widget.opacity),
                            Colors.white.withOpacity(widget.opacity * 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.25, 0.45, 0.6, 0.75, 1.0],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
