import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// An ellipse drawn as one overlapping loop; `clean` closes it neatly.
///
/// Mirrors `loopLines` in `src/lib/ink/shapes.ts`.
List<Line> loopLines(
  Rng rng,
  double cx,
  double cy,
  double rx,
  double ry, {
  double? turns,
  double? a0,
  double? drift,
  double? breathe,
  double? loose,
  bool clean = false,
}) {
  if (clean) {
    final start = a0 ?? rng.range(-2.9, -1.8);
    final steps = math.max(24, ((rx + ry) * 0.6).ceil());
    final turn = 1 + 2.2 / math.max(6, JsMath.pi * (rx + ry));
    final ph = rng.range(0, tau);
    final pts = <Pt>[];
    for (var i = 0; i <= steps; i++) {
      final a = start + (i / steps) * turn * tau;
      final kk = 1 + 0.006 * JsMath.sin(2 * a + ph);
      pts.add((cx + JsMath.cos(a) * rx * kk, cy + JsMath.sin(a) * ry * kk));
    }
    return [
      Line(
        pts,
        o: const StrokeOpts(
          end: StrokeEnd.soft,
          start: StrokeStart.soft,
          wobble: 0.25,
          speed: 1,
          dry: 0,
        ),
      ),
    ];
  }
  final loops = turns ?? rng.range(1.05, 1.18);
  final start = a0 ?? rng.range(-2.9, -1.8);
  final tilt = rng.gauss(0, 0.05) * (loose ?? 1);
  final grow = drift ?? rng.range(-0.07, 0.05);
  final swell = breathe ?? 0.035;
  final ph = rng.range(0, tau);
  final steps = math.max(16, ((rx + ry) * loops * 0.5).ceil());
  final pts = <Pt>[];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps, a = start + t * loops * tau;
    final kk = 1 + swell * JsMath.sin(2 * a + ph) + grow * t;
    final ex = JsMath.cos(a) * rx * kk, ey = JsMath.sin(a) * ry * kk;
    pts.add((
      cx + ex * JsMath.cos(tilt) - ey * JsMath.sin(tilt),
      cy + ex * JsMath.sin(tilt) + ey * JsMath.cos(tilt),
    ));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        end: StrokeEnd.flick,
        start: StrokeStart.pool,
        wobble: 0.7,
        speed: 1,
      ),
    ),
  ];
}

/// Draws a loop (ink by default).
///
/// Mirrors `loop` in `src/lib/ink/shapes.ts`.
void loop(
  Ink ink,
  double cx,
  double cy,
  double rx,
  double ry, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? turns,
  double? a0,
  double? drift,
  double? breathe,
  bool clean = false,
}) => putLines(
  ink,
  'loop',
  (r) => loopLines(
    r,
    cx,
    cy,
    rx,
    ry,
    turns: turns,
    a0: a0,
    drift: drift,
    breathe: breathe,
    loose: loose,
    clean: clean,
  ),
  PenName.ink,
  pen,
  opts,
);
