import 'dart:ui';

import 'package:flutter/animation.dart';

/// The keyframes of upstream's typing indicator CSS
/// (`src/components/ui/typing-indicator.tsx`), as functions of one cycle's
/// progress `t` (0 → 1).
abstract final class TypingIndicatorMotion {
  /// The dots variant's cycle (`2s`).
  static const Duration dotsCycle = Duration(seconds: 2);

  /// The squiggle variant's cycle (`2.2s`).
  static const Duration squiggleCycle = Duration(milliseconds: 2200);

  /// The delay between one dot and the next (`0.4s`).
  static const Duration dotStagger = Duration(milliseconds: 400);

  static const Curve _easeOut = Cubic(0, 0, 0.58, 1);
  static const Curve _easeInOut = Cubic(0.42, 0, 0.58, 1);

  /// `ll-type-dot`: the dot's (opacity, scale).
  static (double, double) dot(double t) {
    if (t <= 0.08) return (0, 0.3);
    if (t <= 0.2) {
      final k = _eased(_easeOut, t, 0.08, 0.2);
      return (k, lerpDouble(0.3, 1.3, k) ?? 1);
    }
    if (t <= 0.3) {
      final k = _eased(_easeOut, t, 0.2, 0.3);
      return (1, lerpDouble(1.3, 1, k) ?? 1);
    }
    return (1, 1);
  }

  /// `ll-type-hop`: the pencil's shift as a fraction of the span (−1 → 0).
  static double hop(double t) {
    if (t <= 0.1) return -1;
    if (t <= 0.3) return -1 + 0.5 * _eased(_easeInOut, t, 0.1, 0.3);
    if (t <= 0.4) return -0.5;
    if (t <= 0.48) return -0.5 + 0.5 * _eased(_easeInOut, t, 0.4, 0.48);
    return 0;
  }

  /// `ll-type-wipe`: how much of the line shows (0 → 1 by 80%).
  static double wipe(double t) {
    if (t >= 0.8) return 1;
    return _eased(_easeInOut, t, 0, 0.8);
  }

  /// `ll-type-walk`: the pencil's shift as a fraction of the span.
  static double walk(double t) => wipe(t) - 1;

  /// [curve] across the keyframe segment from [from] to [to].
  static double _eased(Curve curve, double t, double from, double to) =>
      curve.transform(((t - from) / (to - from)).clamp(0, 1));
}
