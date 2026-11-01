import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The kind of [bracket].
enum BracketKind { square, curly, round }

/// A vertical bracket of height [h]; [dir] 1 opens right, -1 opens left.
///
/// Mirrors `bracketLines` in `src/lib/ink/shapes.ts`.
List<Line> bracketLines(
  Rng rng,
  double x,
  double y,
  double h, {
  BracketKind? kind,
  int? dir,
}) {
  final d = dir ?? 1;
  final tip = clamp(h * 0.12, 3, 9);
  const so = StrokeOpts(end: StrokeEnd.flick, wobble: 0.5);
  switch (kind ?? BracketKind.square) {
    case BracketKind.square:
      final rad = math.min(0.35 * tip, 2.2);
      final pts = <Pt>[
        (x + d * tip * rng.range(0.85, 1.1), y + rng.gauss(0, 0.5)),
        (x + d * rad, y + rng.gauss(0, 0.2)),
        (x + rng.gauss(0, 0.2), y + rad),
        ...seg(
          x + rng.gauss(0, 0.2),
          y + rad,
          x + rng.gauss(0, 0.6),
          y + h - rad,
          rng.gauss(0, 0.004) * h,
          6,
        ).sublist(1),
        (x + d * rad, y + h + rng.gauss(0, 0.2)),
        (x + d * tip * rng.range(0.85, 1.15), y + h + rng.gauss(0, 0.6)),
      ];
      return [Line(pts, o: so)];
    case BracketKind.curly:
      final m = y + h * rng.range(0.47, 0.53);
      return [
        Line([
          (x + d * tip, y),
          (x + 0.35 * d * tip, y + 0.06 * h),
          (x + 0.3 * d * tip, m - 0.12 * h),
          (x - 0.15 * d * tip, m),
          (x + 0.3 * d * tip, m + 0.12 * h),
          (x + 0.35 * d * tip, y + h * 0.94),
          (x + d * tip, y + h),
        ], o: so),
      ];
    case BracketKind.round:
      final pts = <Pt>[];
      for (var i = 0; i <= 12; i++) {
        final t = i / 12;
        pts.add((x + d * tip * (1 - JsMath.sin(JsMath.pi * t)), y + h * t));
      }
      return [Line(pts, o: so)];
  }
}

/// Draws a bracket (pencil by default).
///
/// Mirrors `bracket` in `src/lib/ink/shapes.ts`.
void bracket(
  Ink ink,
  double x,
  double y,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  BracketKind? kind,
  int? dir,
}) => putLines(
  ink,
  'br',
  (r) => bracketLines(r, x, y, h, kind: kind, dir: dir),
  PenName.pencil,
  pen,
  opts,
);
