import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A cloud outline of bumps around an ellipse.
///
/// Mirrors `cloudLines` in `src/lib/ink/shapes.ts`.
List<Line> cloudLines(
  Rng rng,
  double cx,
  double cy,
  double w,
  double h, {
  double? bulge,
}) {
  final rx = w / 2, ry = h / 2;
  final bumps = clamp(
    JsMath.round((JsMath.pi * (rx + ry)) / clamp(0.32 * math.min(w, h), 9, 26)),
    6,
    40,
  ).toInt();
  final a0 = -JsMath.pi / 2 + rng.gauss(0, 0.3);
  final sizes = [for (var i = 0; i < bumps; i++) rng.range(0.75, 1.25)];
  final tot = sizes.fold(0.0, (a, b) => a + b);
  final pts = <Pt>[];
  var a = a0;
  Pt at(double ang) => (cx + JsMath.cos(ang) * rx, cy + JsMath.sin(ang) * ry);
  for (var i = 0; i < bumps + 1; i++) {
    final i2 = i % bumps;
    final da = (sizes[i2] / tot) * tau;
    final p0 = at(a), p1 = at(a + da);
    final l = JsMath.hypot(p1.x - p0.x, p1.y - p0.y);
    final bump = math.min(0.42 * l, bulge ?? l * 0.3) * rng.range(0.8, 1.1);
    final nx = (p0.x + p1.x) / 2 - cx, ny = (p0.y + p1.y) / 2 - cy;
    final nl = JsMath.or(JsMath.hypot(nx, ny), 1);
    final k0 = switch (i) {
      0 => 0,
      _ => 1,
    };
    for (var k = k0; k <= 6; k++) {
      final t = k / 6, b = JsMath.sin(JsMath.pi * t) * bump;
      pts.add((
        p0.x + (p1.x - p0.x) * t + (nx / nl) * b,
        p0.y + (p1.y - p0.y) * t + (ny / nl) * b,
      ));
    }
    a += da;
  }
  pts.add((pts[1].x + 1.5, pts[1].y + 0.6));
  return [
    Line(
      pts,
      o: const StrokeOpts(end: StrokeEnd.flick, wobble: 0.5, speed: 1.05),
    ),
  ];
}

/// Draws a cloud (pencil by default).
///
/// Mirrors `cloud` in `src/lib/ink/shapes.ts`.
void cloud(
  Ink ink,
  double cx,
  double cy,
  double w,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? bulge,
}) => putLines(
  ink,
  'cloud',
  (r) => cloudLines(r, cx, cy, w, h, bulge: bulge),
  PenName.pencil,
  pen,
  opts,
);

/// A zigzag scribble filling the box.
///
/// Mirrors `scribbleLines` in `src/lib/ink/shapes.ts`.
List<Line> scribbleLines(Rng rng, double x, double y, double w, double h) {
  final step = math.max(2.2, 0.28 * h);
  final nn = math.max(3, JsMath.roundInt(w / step));
  final lean = rng.gauss(0.18, 0.08) * h;
  final pts = <Pt>[];
  for (var k = 0; k <= nn; k++) {
    final up = k % 2 == 0;
    final shift = switch (up) {
      true => -lean / 2,
      false => lean / 2,
    };
    final px = clamp(
      x + (k / nn) * w + rng.gauss(0, 0.18 * step) + shift,
      x,
      x + w,
    );
    final py = switch (up) {
      true => y + rng.range(0, 0.2) * h,
      false => y + rng.range(0.8, 1) * h,
    };
    pts.add((px, py));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(end: StrokeEnd.flick, speed: 1.3, wobble: 0.6),
    ),
  ];
}

/// Draws a scribble (red pencil by default).
///
/// Mirrors `scribble` in `src/lib/ink/shapes.ts`.
void scribble(
  Ink ink,
  double x,
  double y,
  double w,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'scrib',
  (r) => scribbleLines(r, x, y, w, h),
  PenName.red,
  pen,
  opts,
);

/// Rays around a center, alternating long and short.
///
/// Mirrors `burstLines` in `src/lib/ink/shapes.ts`.
List<Line> burstLines(Rng rng, double cx, double cy, double r, {int? rays}) {
  final k = rays ?? 10;
  final a0 = rng.range(0, tau);
  final out = <Line>[];
  for (var i = 0; i < k; i++) {
    final a = a0 + (i / k) * tau + rng.gauss(0, 0.07);
    final r0 = r * rng.range(0.42, 0.52);
    final r1 =
        r *
        switch (i % 2) {
          0 => rng.range(0.98, 1.1),
          _ => rng.range(0.78, 0.9),
        };
    out.add(
      Line(
        seg(
          cx + JsMath.cos(a) * r0,
          cy + JsMath.sin(a) * r0,
          cx + JsMath.cos(a) * r1,
          cy + JsMath.sin(a) * r1,
          rng.gauss(0, 0.25),
          3,
        ),
        o: const StrokeOpts(
          end: StrokeEnd.flick,
          start: StrokeStart.soft,
          wobble: 0.3,
          speed: 1.2,
        ),
      ),
    );
  }
  return out;
}

/// Draws a burst (red felt by default).
///
/// Mirrors `burst` in `src/lib/ink/shapes.ts`.
void burst(
  Ink ink,
  double cx,
  double cy,
  double r, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  int? rays,
}) => putLines(
  ink,
  'burst',
  (rg) => burstLines(rg, cx, cy, r, rays: rays),
  PenName.redfelt,
  pen,
  opts,
);
