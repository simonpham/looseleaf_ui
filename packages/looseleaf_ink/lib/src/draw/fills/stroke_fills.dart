import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The side of a box an [edgeBand] shades.
enum EdgeSide { t, r, b, l }

/// Clusters of short slanted strokes shading one side of a box.
///
/// Mirrors `edgeBand` in `src/lib/ink/fills.ts`.
void edgeBand(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  EdgeSide side, {
  double? thick,
  double? gap,
  double? inset,
  Pen? pen,
  double? alpha,
  double? width,
}) {
  final rnd = ink.next('edge');
  final thickness = thick ?? 4;
  final spacing = gap ?? 2.6;
  final horiz = side == EdgeSide.b || side == EdgeSide.t;
  final len = switch (horiz) {
    true => w,
    false => h,
  };
  final dirSign = switch (side == EdgeSide.b || side == EdgeSide.r) {
    true => 1,
    false => -1,
  };
  final pad = inset ?? 2;
  var t = rnd.range(0, spacing) + pad;
  final end = len - pad;
  var inCluster = rnd.integer(3, 7), cl = 0;
  final lines = <Line>[];
  while (t < end) {
    final fade = math.min(math.min(1, t / 9), (len - t) / 9);
    final bell = 0.55 + 0.45 * JsMath.sin((JsMath.pi * (cl + 0.5)) / inCluster);
    final l = thickness * (0.45 + 0.55 * fade) * bell * rnd.range(0.65, 1.2);
    final lean = rnd.range(0.55, 1.2) * l;
    final (p0, p1) = switch (horiz) {
      true => _horizontal(rnd, x, y, h, t, side, dirSign, l, lean),
      false => _vertical(rnd, x, y, w, t, side, dirSign, l, lean),
    };
    lines.add(
      Line(
        seg(p0.x, p0.y, p1.x, p1.y, rnd.gauss(0, 0.2), 3),
        o: StrokeOpts(
          simple: true,
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          speed: 1.5,
          wobble: 0.5,
          alpha: alpha ?? 0.82,
          width: width ?? 0.62,
        ),
      ),
    );
    cl++;
    t += spacing * rnd.range(0.75, 1.3);
    if (cl >= inCluster) {
      cl = 0;
      inCluster = rnd.integer(3, 7);
      t += spacing * rnd.range(0.8, 2.2);
    }
  }
  ink.lines(lines, pen ?? PenName.inkFine);
}

(Pt, Pt) _horizontal(
  Rng rnd,
  double x,
  double y,
  double h,
  double t,
  EdgeSide side,
  int dirSign,
  double l,
  double lean,
) {
  final by = switch (side) {
    EdgeSide.b => y + h,
    _ => y,
  };
  final x0 = x + t;
  final Pt p0 = (x0 + rnd.gauss(0, 0.3), by - dirSign * rnd.range(0, 1));
  return (p0, (x0 - lean * 0.7, by + dirSign * l));
}

(Pt, Pt) _vertical(
  Rng rnd,
  double x,
  double y,
  double w,
  double t,
  EdgeSide side,
  int dirSign,
  double l,
  double lean,
) {
  final bx = switch (side) {
    EdgeSide.r => x + w,
    _ => x,
  };
  final y0 = y + t;
  final Pt p0 = (bx - dirSign * rnd.range(0, 1), y0 + rnd.gauss(0, 0.3));
  return (p0, (bx + dirSign * l, y0 + lean * 0.7));
}

/// [count] short dabs scattered over the box.
///
/// Mirrors `stipple` in `src/lib/ink/fills.ts`.
void stipple(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  int count, {
  Pen? pen,
  double? alpha,
}) {
  final rnd = ink.next('stip');
  final lines = <Line>[];
  for (var i = 0; i < count; i++) {
    final px = x + rnd() * w, py = y + rnd() * h;
    final pts = <Pt>[
      (px, py),
      (px + rnd.range(-0.5, 0.5), py + rnd.range(0.2, 0.9)),
    ];
    lines.add(
      Line(
        pts,
        o: StrokeOpts(
          simple: true,
          width: rnd.range(0.8, 1.5),
          start: StrokeStart.pool,
          end: StrokeEnd.pool,
          wobble: 0,
          alpha: alpha,
        ),
      ),
    );
  }
  ink.lines(lines, pen ?? PenName.inkFine);
}

/// Contour arcs across an ellipse, like shading on a ball.
///
/// Mirrors `contourArcs` in `src/lib/ink/fills.ts`.
void contourArcs(
  Ink ink,
  double cx,
  double cy,
  double rx,
  double ry, {
  int? n,
  int? dir,
  Pen? pen,
  double? alpha,
}) {
  final cnt = n ?? 4;
  final lines = <Line>[];
  for (var i = 0; i < cnt; i++) {
    final t = (i + 0.6) / (cnt + 0.2);
    final y = cy - ry + 2 * ry * t;
    final half =
        rx * JsMath.sqrt(math.max(0, 1 - JsMath.pow((y - cy) / ry, 2)));
    final bulge = ry * 0.28 * (1 - t) + 1;
    lines.add(
      Line(
        seg(cx - half * 0.92, y, cx + half * 0.92, y, bulge * (dir ?? 1), 6),
        o: StrokeOpts(
          simple: true,
          width: 0.75,
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          speed: 1.3,
          wobble: 0.5,
          alpha: alpha,
        ),
      ),
    );
  }
  ink.lines(lines, pen ?? PenName.inkFine);
}

/// A highlighter swipe across the box.
///
/// Mirrors `highlight` in `src/lib/ink/fills.ts`.
void highlight(
  Ink ink,
  double x,
  double y,
  double w,
  double h, {
  Pen? pen,
  double? k,
  StrokeOpts? opts,
}) {
  final rng = ink.next('hl');
  final cy = y + h / 2;
  final x1 = x - (1 + rng() * 3), x2 = x + w + 1 + rng() * 4;
  final y1 = cy + rng.gauss(0, 0.04 * h),
      y2 = cy + rng.gauss(0, 0.05 * h) - 0.004 * w;
  final Pt mid = ((x1 + x2) / 2, (y1 + y2) / 2 + rng.gauss(0, 0.04 * h));
  final p = (pen ?? PenName.hi).spec;
  final end = switch (rng() < 0.5) {
    true => StrokeEnd.flick,
    false => StrokeEnd.pool,
  };
  final o = StrokeOpts(
    width: (h * (k ?? 0.86)) / p.w,
    end: end,
    start: StrokeStart.pool,
    wobble: 0.6,
  ).merge(opts);
  ink.stroke([(x1, y1), mid, (x2, y2)], p, o);
}
