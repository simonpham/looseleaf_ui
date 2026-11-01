import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// [d] degrees in radians.
///
/// Mirrors `deg` in `src/lib/ink/charts/chart-polar.ts`.
double deg(double d) => (d * JsMath.pi) / 180;

/// The point [r] from `(cx, cy)` at angle [a] (radians, clockwise from
/// 12 o'clock).
///
/// Mirrors `polar` in `src/lib/ink/charts/chart-polar.ts`.
Pt polar(double cx, double cy, double r, double a) =>
    (cx + r * JsMath.sin(a), cy - r * JsMath.cos(a));

/// The angle of `(x, y)` around `(cx, cy)`, in `[0, 2π)`.
///
/// Mirrors `angleOf` in `src/lib/ink/charts/chart-polar.ts`.
double angleOf(double cx, double cy, double x, double y) {
  final a = JsMath.atan2(x - cx, cy - y);
  if (a < 0) return a + tau;
  return a;
}

/// Points along an arc, about [step] px apart.
///
/// Mirrors `arcPts` in `src/lib/ink/charts/chart-polar.ts`.
List<Pt> arcPts(
  double cx,
  double cy,
  double r,
  double a0,
  double a1, [
  double step = 4,
]) {
  final n = math.max(2, (((a1 - a0).abs() * r) / step).ceil());
  return [
    for (var i = 0; i <= n; i++) polar(cx, cy, r, a0 + ((a1 - a0) * i) / n),
  ];
}

/// A ring sector (or a pie wedge when [r0] is about 0) as a polygon.
///
/// Mirrors `sectorPoly` in `src/lib/ink/charts/chart-polar.ts`.
List<Pt> sectorPoly(
  double cx,
  double cy,
  double r0,
  double r1,
  double a0,
  double a1, [
  double step = 4,
]) {
  final outer = arcPts(cx, cy, r1, a0, a1, step);
  if (r0 <= 0.5) return [(cx, cy), ...outer];
  return [...outer, ...arcPts(cx, cy, r0, a1, a0, step)];
}

/// The box around [pts], grown by [pad].
///
/// Mirrors `boundsOf` in `src/lib/ink/charts/chart-polar.ts`.
({double x, double y, double w, double h}) boundsAround(
  List<Pt> pts,
  double pad,
) {
  var x0 = double.infinity;
  var y0 = double.infinity;
  var x1 = double.negativeInfinity;
  var y1 = double.negativeInfinity;
  for (final p in pts) {
    x0 = math.min(x0, p.x);
    y0 = math.min(y0, p.y);
    x1 = math.max(x1, p.x);
    y1 = math.max(y1, p.y);
  }
  return (x: x0 - pad, y: y0 - pad, w: x1 - x0 + 2 * pad, h: y1 - y0 + 2 * pad);
}

/// Label sizes of a polar chart.
typedef PolarMetrics = ({
  LabelFont font,
  double tick,
  double value,
  double center,
});

/// The label sizes of a polar chart in [bucket].
PolarMetrics polarMetrics(Bucket bucket, bool calm) {
  final small = bucket == Bucket.sm;
  if (calm) {
    return (
      font: LabelFont.hand,
      tick: 12.5,
      value: 12.5,
      center: switch (small) {
        true => 22,
        false => 28,
      },
    );
  }
  return (
    font: LabelFont.script,
    tick: switch (small) {
      true => 14,
      false => 15,
    },
    value: 15,
    center: switch (small) {
      true => 30,
      false => 40,
    },
  );
}

/// The `Loading` / `No data` text.
String stateTextOf(String? text, bool loading) =>
    text ??
    switch (loading) {
      true => 'Loading',
      false => 'No data',
    };
