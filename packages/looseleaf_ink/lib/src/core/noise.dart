import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';

/// Smooth 1D value noise over `[0, length]`, a Catmull-Rom spline through
/// random knots spaced [wavelength] apart.
///
/// Mirrors `noise1` in `src/lib/ink/noise.ts`.
double Function(double) noise1(Rng rng, double length, double wavelength) {
  final n = math.max(6, (length / wavelength).ceil() + 6);
  final k = Float64List(n);
  for (var i = 0; i < n; i++) {
    k[i] = rng() * 2 - 1;
  }
  final off = rng() * wavelength;
  final maxI = n - 3;
  return (s) {
    final u = (s + off) / wavelength;
    final fl = u.floor();
    final i = math.max(1, math.min(maxI, fl + 1));
    final t = switch (fl + 1 > maxI) {
      true => 1.0,
      false => u - fl,
    };
    final p0 = k[i - 1], p1 = k[i], p2 = k[i + 1], p3 = k[i + 2];
    return 0.5 *
        (2 * p1 +
            (-p0 + p2) * t +
            (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t +
            (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  };
}

/// A sum of sines with random phases, one per period.
///
/// Mirrors `wander` in `src/lib/ink/noise.ts`.
double Function(double) wander(Rng rng, List<double> periods) {
  final phases = [for (final _ in periods) rng() * JsMath.pi * 2];
  return (x) {
    var v = 0.0;
    for (var i = 0; i < periods.length; i++) {
      v += JsMath.sin((x / periods[i]) * JsMath.pi * 2 + phases[i]) / (i + 1);
    }
    return v * 0.62;
  };
}
