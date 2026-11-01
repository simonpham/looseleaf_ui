import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A hand-drawn rectangle in one stroke, starting and overshooting on top.
///
/// Mirrors `boxLines` in `src/lib/ink/shapes.ts`.
List<Line> boxLines(
  Rng rng,
  double x,
  double y,
  double w,
  double h, {
  double? corner,
  double? loose,
  double? wobble,
}) {
  final k = loose ?? 1;
  final m = math.min(w, h);
  final jc = clamp(0.012 * m, 0.12, 0.4) * k;
  final tilt = rng.gauss(0, 0.0012) * k;
  final rad = corner ?? clamp(m * 0.09, 0.9, 3.4);
  Pt c(double px, double py, double sy) =>
      (px + rng.gauss(0, jc), py + rng.gauss(0, jc) + sy * tilt * w);
  final tl = c(x, y, 0),
      tr = c(x + w, y, 1),
      br = c(x + w, y + h, 1),
      bl = c(x, y + h, 0);
  double lift(double l) => rng.range(0.05, 0.32) * clamp(l / 110, 0.3, 1.2) * k;
  double drift(double l) => rng.gauss(0, 0.1) * clamp(l / 40, 0.4, 1) * k;
  final t0 = rng.range(0.35, 0.65);
  final Pt s = (tl.x + (tr.x - tl.x) * t0, tl.y + (tr.y - tl.y) * t0);
  final run = math.min(0.06 * w, rng.range(1.6, 2.6));
  final vs = <Pt>[s, tr, br, bl, tl, (s.x + run, s.y)];
  final bows = [
    -lift(w * (1 - t0)),
    drift(h),
    lift(w),
    drift(h),
    -lift(w * t0 + run),
  ];
  return [
    Line(
      chain(vs, bows, rad, rng),
      o: StrokeOpts(
        speed: 1,
        wobble: 0.28 * (wobble ?? 1),
        dry: 0,
        end: StrokeEnd.soft,
        start: StrokeStart.soft,
      ),
    ),
  ];
}

/// Draws a box (ink by default).
///
/// Mirrors `box` in `src/lib/ink/shapes.ts`.
void box(
  Ink ink,
  double x,
  double y,
  double w,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? corner,
  double? wobble,
}) => putLines(
  ink,
  'box',
  (r) => boxLines(r, x, y, w, h, corner: corner, loose: loose, wobble: wobble),
  PenName.ink,
  pen,
  opts,
);
