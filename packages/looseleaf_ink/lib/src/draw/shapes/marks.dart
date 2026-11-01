import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A check mark in an `s`-sized box.
///
/// Mirrors `checkLines` in `src/lib/ink/shapes.ts`.
List<Line> checkLines(Rng rng, double x, double y, double s) {
  final Pt a = (x + s * rng.range(0, 0.1), y + s * rng.range(0.45, 0.58));
  final Pt b = (x + s * rng.range(0.32, 0.42), y + s * rng.range(0.86, 0.96));
  final Pt c = (x + s * rng.range(0.9, 1.02), y + s * rng.range(0, 0.1));
  final Pt mid = (
    b.x + (c.x - b.x) * 0.45 - s * 0.05,
    b.y + (c.y - b.y) * 0.45 + s * 0.02,
  );
  return [
    Line(
      [...seg(a.x, a.y, b.x, b.y, s * 0.03, 4), mid, c],
      o: const StrokeOpts(
        start: StrokeStart.pool,
        end: StrokeEnd.flick,
        speed: 1.1,
        wobble: 0.5,
      ),
    ),
  ];
}

/// Draws a check mark (green felt by default).
///
/// Mirrors `check` in `src/lib/ink/shapes.ts`.
void check(
  Ink ink,
  double x,
  double y,
  double s, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'check',
  (r) => checkLines(r, x, y, s),
  PenName.greenfelt,
  pen,
  opts,
);

/// An X in an `s`-sized box.
///
/// Mirrors `crossLines` in `src/lib/ink/shapes.ts`.
List<Line> crossLines(Rng rng, double x, double y, double s) {
  double j() => rng.gauss(0, 0.04 * s);
  const o = StrokeOpts(end: StrokeEnd.flick, wobble: 0.5);
  final first = seg(
    x + j(),
    y + j(),
    x + s + j(),
    y + s + j(),
    rng.gauss(0, 0.03 * s),
    5,
  );
  final second = seg(
    x + s + j(),
    y + j(),
    x + j(),
    y + s + j(),
    rng.gauss(0, 0.03 * s),
    5,
  );
  return [Line(first, o: o), Line(second, o: o)];
}

/// Draws an X (red felt by default).
///
/// Mirrors `cross` in `src/lib/ink/shapes.ts`.
void cross(
  Ink ink,
  double x,
  double y,
  double s, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'cross',
  (r) => crossLines(r, x, y, s),
  PenName.redfelt,
  pen,
  opts,
);

/// A three-stroke asterisk.
///
/// Mirrors `asteriskLines` in `src/lib/ink/shapes.ts`.
List<Line> asteriskLines(Rng rng, double cx, double cy, double s) {
  final out = <Line>[];
  for (var k = 0; k < 3; k++) {
    final a = JsMath.pi / 2 + (k * JsMath.pi) / 3 + rng.gauss(0, 0.07);
    final l = 0.5 * s * rng.range(0.85, 1);
    final Pt c = (cx + rng.gauss(0, 0.03 * s), cy + rng.gauss(0, 0.03 * s));
    out.add(
      Line(
        seg(
          c.x - JsMath.cos(a) * l,
          c.y - JsMath.sin(a) * l,
          c.x + JsMath.cos(a) * l,
          c.y + JsMath.sin(a) * l,
          rng.gauss(0, 0.3),
          4,
        ),
        o: const StrokeOpts(end: StrokeEnd.flick, wobble: 0.4),
      ),
    );
  }
  return out;
}

/// Draws an asterisk (red felt by default).
///
/// Mirrors `asterisk` in `src/lib/ink/shapes.ts`.
void asterisk(
  Ink ink,
  double cx,
  double cy,
  double s, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'ast',
  (r) => asteriskLines(r, cx, cy, s),
  PenName.redfelt,
  pen,
  opts,
);

/// An inward spiral.
///
/// Mirrors `spiralLines` in `src/lib/ink/shapes.ts`.
List<Line> spiralLines(
  Rng rng,
  double cx,
  double cy,
  double r0, {
  double? turns,
  int? steps,
  double? shrink,
}) {
  final loops = turns ?? 2.3;
  final count = steps ?? 26;
  final a0 = rng.range(0, tau);
  final pts = <Pt>[];
  for (var i = 0; i <= count; i++) {
    final t = i / count;
    final r = r0 * (1 - (shrink ?? 0.78) * t);
    final a = a0 + t * loops * tau + rng.range(0, 0.2);
    pts.add((cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r * 0.94));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        end: StrokeEnd.pool,
        start: StrokeStart.soft,
        wobble: 0.3,
        speed: 0.9,
      ),
    ),
  ];
}

/// Draws a spiral (ink by default).
///
/// Mirrors `spiral` in `src/lib/ink/shapes.ts`.
void spiral(
  Ink ink,
  double cx,
  double cy,
  double r, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? turns,
  int? steps,
  double? shrink,
}) => putLines(
  ink,
  'spiral',
  (rg) =>
      spiralLines(rg, cx, cy, r, turns: turns, steps: steps, shrink: shrink),
  PenName.ink,
  pen,
  opts,
);

/// A five-point star in one stroke.
///
/// Mirrors `starLines` in `src/lib/ink/shapes.ts`.
List<Line> starLines(Rng rng, double cx, double cy, double r) {
  final pts = <Pt>[];
  final a0 = -JsMath.pi / 2 + rng.gauss(0, 0.06);
  for (var i = 0; i <= 5; i++) {
    final a = a0 + ((i * 2) % 5) * (tau / 5);
    final rr = r * rng.range(0.9, 1.05);
    pts.add((cx + JsMath.cos(a) * rr, cy + JsMath.sin(a) * rr));
  }
  pts.add((pts[0].x + rng.gauss(0, 0.05 * r) + 0.1 * r, pts[0].y + 0.18 * r));
  return [
    Line(
      pts,
      o: const StrokeOpts(poly: true, wobble: 0.5, end: StrokeEnd.flick),
    ),
  ];
}

/// Draws a star (ink by default).
///
/// Mirrors `star` in `src/lib/ink/shapes.ts`.
void star(
  Ink ink,
  double cx,
  double cy,
  double r, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'star',
  (rg) => starLines(rg, cx, cy, r),
  PenName.ink,
  pen,
  opts,
);

/// Tally marks in gates of five, and their total width.
///
/// Mirrors `tallyLines` in `src/lib/ink/shapes.ts`.
({List<Line> lines, double width}) tallyLines(
  Rng rng,
  double x,
  double y,
  int count,
  double gh,
) {
  final step = 0.26 * gh, gw = 1.05 * gh + 6;
  final lines = <Line>[];
  var gx = x;
  var left = count;
  while (left > 0) {
    final n5 = math.min(5, left);
    left -= n5;
    final up = math.min(4, n5);
    for (var i = 0; i < up; i++) {
      final lx = gx + i * step + rng.gauss(0, 0.35);
      final pts = seg(
        lx + rng.gauss(0.4, 0.4),
        y + rng.gauss(0, 0.5),
        lx - rng.gauss(0.3, 0.3),
        y + gh + rng.gauss(0, 0.6),
        rng.gauss(0, 0.4),
        4,
      );
      final end = switch (rng.chance(0.5)) {
        true => StrokeEnd.flick,
        false => StrokeEnd.pool,
      };
      lines.add(Line(pts, o: StrokeOpts(end: end, speed: 1.15, wobble: 0.5)));
    }
    if (n5 == 5) {
      lines.add(
        Line(
          seg(
            gx - 0.55 * step,
            y + 0.78 * gh + rng.gauss(0, 0.6),
            gx + 3.55 * step,
            y + 0.2 * gh + rng.gauss(0, 0.6),
            rng.gauss(0, 0.5),
            5,
          ),
          o: const StrokeOpts(end: StrokeEnd.flick, speed: 1.25, wobble: 0.5),
        ),
      );
    }
    gx += gw;
  }
  return (lines: lines, width: gx - x);
}

/// Draws tally marks (ink by default) and returns their width.
///
/// Mirrors `tally` in `src/lib/ink/shapes.ts`.
double tally(
  Ink ink,
  double x,
  double y,
  int count,
  double gh, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) {
  final t = tallyLines(ink.next('tally'), x, y, count, gh);
  ink.lines(t.lines, pen ?? PenName.ink, opts);
  return t.width;
}
