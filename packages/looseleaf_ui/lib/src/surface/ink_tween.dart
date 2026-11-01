import 'package:flutter/animation.dart';

/// One animated number that eases to each new target with its own duration
/// and curve, like a CSS transition. Overshooting curves are allowed.
class InkTween {
  InkTween(TickerProvider vsync, double initial)
    : _controller = AnimationController.unbounded(
        vsync: vsync,
        value: initial,
      ),
      _target = initial;

  final AnimationController _controller;
  double _target;

  Animation<double> get animation => _controller;
  double get value => _controller.value;

  /// Eases to [target] over [duration] with [curve]; jumps when [duration]
  /// is zero.
  void to(double target, Duration duration, Curve curve) {
    if (target == _target) return;
    _target = target;
    if (duration == Duration.zero) {
      _controller.value = target;
      return;
    }
    _controller.animateTo(target, duration: duration, curve: curve);
  }

  /// Jumps to [from], then eases to [target], replaying a CSS animation.
  void replay(double from, double target, Duration duration, Curve curve) {
    _controller.value = from;
    _target = from;
    to(target, duration, curve);
  }

  void dispose() => _controller.dispose();
}
