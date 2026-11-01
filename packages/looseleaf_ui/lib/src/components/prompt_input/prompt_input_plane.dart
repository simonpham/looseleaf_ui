import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Flies [child] off up and to the right and back in from below whenever
/// [flight] goes up: the submit's paper plane.
///
/// Mirrors the `ll-plane` keyframes in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputPlane extends StatefulWidget {
  const PromptInputPlane({
    super.key,
    required this.flight,
    required this.child,
  });

  /// How many times a message was sent.
  final int flight;

  final Widget child;

  @override
  State<PromptInputPlane> createState() => _PromptInputPlaneState();
}

/// One `ll-plane` keyframe: offset, turn in degrees, scale, opacity.
typedef _Frame = ({Offset offset, double turn, double scale, double opacity});

class _PromptInputPlaneState extends State<PromptInputPlane>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 900);
  static const _rest = (
    offset: Offset.zero,
    turn: 0.0,
    scale: 1.0,
    opacity: 1.0,
  );
  static const _gone = (
    offset: Offset(20, -18),
    turn: -16.0,
    scale: 0.85,
    opacity: 0.0,
  );
  static const _back = (
    offset: Offset(-16, 12),
    turn: 8.0,
    scale: 0.85,
    opacity: 0.0,
  );
  static const List<(double, _Frame)> _keys = [
    (0, _rest),
    (0.46, _gone),
    (0.47, _back),
    (1, _rest),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  @override
  void didUpdateWidget(PromptInputPlane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flight <= oldWidget.flight) return;
    if (InkMotion.reducedIn(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The pose at [t], eased in and out within each keyframe span like CSS.
  static _Frame _at(double t) {
    for (var i = 1; i < _keys.length; i++) {
      final (end, to) = _keys[i];
      if (t > end) continue;
      final (start, from) = _keys[i - 1];
      final local = Curves.easeInOut.transform(
        ((t - start) / (end - start)).clamp(0.0, 1.0),
      );
      double lerp(double a, double b) => a + (b - a) * local;
      return (
        offset: Offset.lerp(from.offset, to.offset, local) ?? Offset.zero,
        turn: lerp(from.turn, to.turn),
        scale: lerp(from.scale, to.scale),
        opacity: lerp(from.opacity, to.opacity),
      );
    }
    return _rest;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      if (!_controller.isAnimating) return child ?? const SizedBox.shrink();
      final pose = _at(_controller.value);
      return Opacity(
        opacity: pose.opacity,
        child: Transform.translate(
          offset: pose.offset,
          child: Transform.rotate(
            angle: pose.turn * math.pi / 180,
            child: Transform.scale(scale: pose.scale, child: child),
          ),
        ),
      );
    },
    child: widget.child,
  );
}
