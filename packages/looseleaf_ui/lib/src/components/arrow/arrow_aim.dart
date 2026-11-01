import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The offset from the centre of [host] to the edge of [target], [gap]
/// short of it, rounded to even pixels; null when the centres coincide or
/// the host's centre is inside the target.
///
/// Mirrors `vectorTo` in upstream `src/components/ui/arrow.tsx`.
Offset? arrowVector(Rect host, Rect target, double gap) {
  final c = host.center;
  final v = target.center - c;
  final length = v.distance;
  if (length < 1) return null;
  double enter(double lo, double hi, double o, double d) {
    if (d == 0) {
      return switch (o >= lo && o <= hi) {
        true => double.negativeInfinity,
        false => double.infinity,
      };
    }
    return math.min((lo - o) / d, (hi - o) / d);
  }

  final t = math.max(
    enter(target.left, target.right, c.dx, v.dx),
    enter(target.top, target.bottom, c.dy, v.dy),
  );
  if (!(t >= 0 && t <= 1)) return null;
  final reach = math.max(0, length * t - gap);
  double even(double value) => (value / 2).roundToDouble() * 2;
  return Offset(
    even(v.dx / length * reach),
    even(v.dy / length * reach),
  );
}
