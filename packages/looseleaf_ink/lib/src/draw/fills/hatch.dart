import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

(Pt, Pt) _loosen(
  Pt a,
  Pt b,
  Rng rng,
  double over,
  double under, [
  double cap = 0.3,
]) {
  final l = JsMath.or(JsMath.hypot(b.x - a.x, b.y - a.y), 1);
  final Pt t = ((b.x - a.x) / l, (b.y - a.y) / l);
  double ext() => switch (rng() < 0.3) {
    true => -rng() * under,
    false => rng() * over,
  };
  final e0 = math.max(ext(), -cap * l), e1 = math.max(ext(), -cap * l);
  return ((a.x - t.x * e0, a.y - t.y * e0), (b.x + t.x * e1, b.y + t.y * e1));
}

/// The rectangle `[x, y, w, h]` as a polygon, for [hatch] regions.
List<Pt> rectRegion(double x, double y, double w, double h) => [
  (x, y),
  (x + w, y),
  (x + w, y + h),
  (x, y + h),
];

/// Hand hatching across a polygon (use [rectRegion] for a box), with up to
/// three crossing tones. [crossAngle] sets the cross pass offset in degrees
/// (upstream `cross: number`); [cross] alone uses 78°.
///
/// Mirrors `hatch` in `src/lib/ink/fills.ts`.
void hatch(
  Ink ink,
  List<Pt> poly, {
  double? angle,
  double? gap,
  bool cross = false,
  double? crossAngle,
  int? tones,
  double? over,
  double? under,
  double? skip,
  Pen? pen,
  double? alpha,
  double? width,
  StrokeOpts? opts,
}) {
  final rng = ink.next('hatch');
  final spacing = gap ?? 4;
  final a0 = (angle ?? 60) + rng.gauss(0, 1.2);
  final crossing =
      cross || (crossAngle != null && crossAngle != 0 && !crossAngle.isNaN);
  final toneCount =
      tones ??
      switch (crossing) {
        true => 2,
        false => 1,
      };
  final crossOff = crossAngle ?? 78;
  final passes = [
    a0,
    if (toneCount >= 2) a0 + crossOff,
    if (toneCount >= 3) a0 + crossOff / 2 + 8,
  ];
  final skipP = skip ?? 0;
  for (var pi = 0; pi < passes.length; pi++) {
    final g =
        spacing *
        switch (pi) {
          0 => 1.0,
          _ => 1.3,
        };
    final spans = scanSpans(
      poly,
      (passes[pi] * JsMath.pi) / 180,
      g,
      rng,
      jitter: 0.15,
      even: false,
    );
    final lines = <Line>[];
    var flip = false;
    for (final sp in spans) {
      if (skipP != 0 && !skipP.isNaN && rng.chance(skipP)) continue;
      var (la, lb) = _loosen(sp.a, sp.b, rng, over ?? 1.6, under ?? 1.4);
      flip = !flip;
      if (flip) (la, lb) = (lb, la);
      final Pt mid = (
        (la.x + lb.x) / 2 + rng.gauss(0, 0.25),
        (la.y + lb.y) / 2 + rng.gauss(0, 0.25),
      );
      final start = switch (rng.chance(0.4)) {
        true => StrokeStart.pool,
        false => StrokeStart.soft,
      };
      lines.add(
        Line(
          [la, mid, lb],
          o: StrokeOpts(
            simple: true,
            end: StrokeEnd.flick,
            start: start,
            speed: 1.3,
            wobble: 0.5,
            width: (width ?? 1) * rng.range(0.85, 1.15),
            alpha: alpha ?? 0.85,
          ),
        ),
      );
    }
    ink.lines(lines, pen ?? PenName.pencil, opts);
  }
}
