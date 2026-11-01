import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// How a toast arrives: tossed in from the side (upstream `ll-toss`, for
/// toasters on the right) or dropped from above (`ll-drop`, elsewhere).
enum ToastArrival { toss, drop }

/// Plays a toast's arrival once, when it mounts; nothing where motion is
/// reduced.
class ToastEntrance extends StatefulWidget {
  const ToastEntrance({super.key, required this.arrival, required this.child});

  final ToastArrival arrival;
  final Widget child;

  /// `--ll-dur-toss`.
  static const Duration toss = Duration(milliseconds: 440);

  /// `--ll-dur-drop`.
  static const Duration drop = Duration(milliseconds: 340);

  @override
  State<ToastEntrance> createState() => _ToastEntranceState();
}

class _ToastEntranceState extends State<ToastEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: switch (widget.arrival) {
      ToastArrival.toss => ToastEntrance.toss,
      ToastArrival.drop => ToastEntrance.drop,
    },
    value: 1,
  );

  static const double _degree = math.pi / 180;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock.value < 1 || _clock.isAnimating) return;
    if (InkMotion.reducedIn(context)) return;
    _clock.forward(from: 0);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// The keyframe pose at [t]: offset, turn in degrees, scale, opacity.
  (Offset, double, double, double) _pose(double t) => switch (widget.arrival) {
    ToastArrival.toss => _lerpKeys(t, const [
      (0, Offset(46, 34), 14, 0.92, 0),
      (0.6, Offset(-2, -2), -1.5, 1.01, 1),
      (1, Offset.zero, 0, 1, 1),
    ]),
    ToastArrival.drop => _lerpKeys(t, const [
      (0, Offset(0, -26), -2.4, 1.05, 0),
      (0.62, Offset(0, 2), 0.35, 0.995, 1),
      (0.82, Offset(0, -1), -0.1, 1, 1),
      (1, Offset.zero, 0, 1, 1),
    ]),
  };

  static (Offset, double, double, double) _lerpKeys(
    double t,
    List<(double, Offset, double, double, double)> keys,
  ) {
    for (var i = 1; i < keys.length; i++) {
      final (end, offset, turn, scale, opacity) = keys[i];
      if (t > end) continue;
      final (start, from, fromTurn, fromScale, fromOpacity) = keys[i - 1];
      final k = (t - start) / (end - start);
      return (
        Offset.lerp(from, offset, k) ?? offset,
        fromTurn + (turn - fromTurn) * k,
        fromScale + (scale - fromScale) * k,
        fromOpacity + (opacity - fromOpacity) * k,
      );
    }
    return (Offset.zero, 0, 1, 1);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (context, child) {
      final (offset, turn, scale, opacity) = _pose(
        InkMotion.settle.transform(_clock.value),
      );
      return Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: turn * _degree,
            child: Transform.scale(scale: scale, child: child),
          ),
        ),
      );
    },
    child: widget.child,
  );
}
