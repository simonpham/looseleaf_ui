import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Draws a point marker of radius [r] at [x], [y]; [rich] draws circles
/// as inked loops instead of blots and wobbles the other shapes.
///
/// Mirrors `drawMarker` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void drawMarker(
  Ink ink,
  MarkerShape shape,
  double x,
  double y,
  double r, {
  required PaintKey color,
  required bool rich,
  Pen? pen,
  double? width,
}) {
  if (shape == MarkerShape.none) return;
  final rng = ink.next('mk');
  double j() => rng.gauss(0, r * 0.05);
  final p = pen ?? PenName.inkFine;
  final opts = StrokeOpts(
    color: color,
    simple: !rich,
    width: width ?? 1.15,
    wobble: 0.5,
    start: StrokeStart.soft,
    end: StrokeEnd.soft,
  );
  final poly = opts.copyWith(poly: true);
  final flick = opts.copyWith(end: StrokeEnd.flick);
  Pt at(double a, [double k = 1]) => (
    x + JsMath.cos(a) * r * k + j(),
    y + JsMath.sin(a) * r * k + j(),
  );
  switch (shape) {
    case MarkerShape.circle when rich:
      loop(
        ink,
        x,
        y,
        r,
        r * 0.96,
        pen: p,
        opts: StrokeOpts(color: color, width: width ?? 1.15, simple: true),
        turns: 1.1,
      );
    case MarkerShape.circle:
      ink.dot(x, y, r * 0.62, PenName.ink, StrokeOpts(color: color));
    case MarkerShape.square:
      final s = r * 0.92;
      ink.stroke(
        [
          (x - s, y - s + j()),
          (x + s + j(), y - s),
          (x + s, y + s + j()),
          (x - s + j(), y + s),
          (x - s, y - s + r * 0.35),
        ],
        p,
        poly,
      );
    case MarkerShape.triangle:
      final p0 = at(-JsMath.pi / 2, 1.1);
      final p1 = at(JsMath.pi / 6, 1.1);
      final p2 = at((5 * JsMath.pi) / 6, 1.1);
      ink.stroke([p0, p1, p2, p0, (p1.x - r * 0.3, p1.y - r * 0.4)], p, poly);
    case MarkerShape.diamond:
      final p0 = at(-JsMath.pi / 2, 1.2);
      final p1 = at(0);
      final p2 = at(JsMath.pi / 2, 1.2);
      final p3 = at(JsMath.pi);
      ink.stroke(
        [
          p0,
          p1,
          p2,
          p3,
          p0,
          (p1.x - r * 0.2, p1.y - r * 0.3),
        ],
        p,
        poly,
      );
    case MarkerShape.cross:
      final s = r * 0.85;
      ink
        ..stroke([(x - s, y - s), (x + s, y + s + j())], p, flick)
        ..stroke([(x + s, y - s), (x - s, y + s + j())], p, flick);
    case MarkerShape.plus || MarkerShape.none:
      final s = r * 1.05;
      ink
        ..stroke([(x - s, y + j()), (x + s, y + j())], p, flick)
        ..stroke([(x + j(), y - s), (x + j(), y + s)], p, flick);
  }
}

List<double> _cumulative(List<Pt> pts) {
  final out = [0.0];
  for (var i = 1; i < pts.length; i++) {
    out.add(
      out[i - 1] +
          JsMath.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y),
    );
  }
  return out;
}

List<Pt> _slicePath(List<Pt> pts, List<double> cum, double a, double b) {
  Pt at(double d) {
    var i = 1;
    while (i < cum.length - 1 && cum[i] < d) {
      i++;
    }
    final t = (d - cum[i - 1]) / JsMath.or(cum[i] - cum[i - 1], 1);
    return (
      pts[i - 1].x + (pts[i].x - pts[i - 1].x) * t,
      pts[i - 1].y + (pts[i].y - pts[i - 1].y) * t,
    );
  }

  return [
    at(a),
    for (var i = 0; i < pts.length; i++)
      if (cum[i] > a && cum[i] < b) pts[i],
    at(b),
  ];
}

/// Strokes the polyline [pts] with [pen] in [color], solid or broken into
/// [dash] dashes and dots.
///
/// Mirrors `drawPolyline` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void drawPolyline(
  Ink ink,
  List<Pt> pts,
  Dash dash,
  Pen pen, {
  required PaintKey color,
  double? width,
  bool? simple,
  bool? poly,
  double? alpha,
}) {
  if (pts.length < 2) return;
  final base = StrokeOpts(
    color: color,
    width: width ?? 1,
    simple: simple,
    alpha: alpha,
    poly: poly ?? true,
    wobble: 0.22,
    dry: 0,
  );
  final soft = base.copyWith(start: StrokeStart.soft, end: StrokeEnd.soft);
  if (dash == Dash.solid) {
    ink.stroke(pts, pen, soft);
    return;
  }
  final cum = _cumulative(pts);
  final total = cum[cum.length - 1];
  final dotR = 1.5 * (width ?? 1);
  final dot = StrokeOpts(color: color);
  if (dash == Dash.dotted) {
    for (var d = 0.0; d < total; d += 0.1 + 6.5) {
      final p = _slicePath(pts, cum, d, math.min(total, d + 0.6));
      ink.dot(p[0].x, p[0].y, dotR, PenName.ink, dot);
    }
    return;
  }
  final on = switch (dash) {
    Dash.dashed => 11.0,
    _ => 12.0,
  };
  final off = switch (dash) {
    Dash.dashed => 6.0,
    _ => 5.0,
  };
  final dashes = soft.copyWith(simple: true);
  var d = 0.0;
  for (var k = 0; d < total && k < 400; k++) {
    final len = switch (dash == Dash.dashdot && k.isOdd) {
      true => 1.2,
      false => on,
    };
    final piece = _slicePath(pts, cum, d, math.min(total, d + len));
    switch (piece) {
      case [_, _, ...] when len > 2:
        ink.stroke(piece, pen, dashes);
      case [final first, ...]:
        ink.dot(first.x, first.y, dotR, PenName.ink, dot);
    }
    d += len + off;
  }
}

/// The plot area of an XY chart.
typedef AxisFrame = ({double x0, double y0, double x1, double y1});

const StrokeOpts _gridOpts = StrokeOpts(
  alpha: 0.45,
  width: 0.8,
  simple: true,
  wobble: 0.12,
  dry: 0,
);

/// Faint pencil gridlines at [positions]: across the plot when [vertical]
/// (a vertical value axis), down it otherwise, skipping the axis itself.
///
/// Mirrors `drawGrid` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void drawGrid(
  Ink ink,
  List<double> positions,
  AxisFrame frame,
  bool vertical,
) {
  for (final p in positions) {
    if (vertical) {
      if ((p - frame.y1).abs() < 1.5) continue;
      line(
        ink,
        frame.x0 + 3,
        p,
        frame.x1,
        p,
        pen: PenName.pencilFine,
        opts: _gridOpts,
      );
      continue;
    }
    if ((p - frame.x0).abs() < 1.5) continue;
    line(
      ink,
      p,
      frame.y0 - 2,
      p,
      frame.y1 - 2,
      pen: PenName.pencilFine,
      opts: _gridOpts,
    );
  }
}

/// The inked axes of [f]: the bottom ([x]) and left ([y]) rules, plus a
/// zero line at [zeroY] when it is off the bottom.
///
/// Mirrors `drawAxisLines` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void drawAxisLines(
  Ink ink,
  AxisFrame f, {
  required bool x,
  required bool y,
  required bool calm,
  double? zeroY,
}) {
  if (x) {
    line(
      ink,
      f.x0,
      f.y1,
      f.x1,
      f.y1,
      pen: PenName.inkFine,
      opts: StrokeOpts(
        simple: calm,
        width: switch (calm) {
          true => 0.85,
          false => 1.05,
        },
        wobble: 0.15,
        dry: 0,
      ),
    );
  }
  if (y) {
    line(
      ink,
      f.x0,
      f.y1,
      f.x0,
      f.y0 - 2,
      pen: PenName.inkFine,
      opts: StrokeOpts(
        simple: calm,
        width: 0.9,
        wobble: 0.15,
        dry: 0,
        alpha: 0.8,
      ),
    );
  }
  if (zeroY case final z? when (z - f.y1).abs() > 2) {
    line(
      ink,
      f.x0,
      z,
      f.x1,
      z -
          switch (calm) {
            true => 0,
            false => 0.6,
          },
      pen: PenName.inkFine,
      opts: const StrokeOpts(simple: true, width: 0.95, alpha: 0.85),
    );
  }
}

/// The pulsing pencil ring (and inner ring, past radius 4) an empty or
/// loading round chart shows.
///
/// Mirrors `ghostRing` in `src/lib/ink/recipes/chart-ink/polar.ts`.
void drawGhostRing(Ink ink, double cx, double cy, double radius, double r0) {
  ink.group(GroupAttrs(part: 'pulse'), () {
    ink.stroke(
      arcPts(cx, cy, radius, 0.1, tau + 0.16, 5),
      PenName.pencil,
      const StrokeOpts(
        simple: true,
        alpha: 0.7,
        width: 0.9,
        wobble: 0.8,
        poly: true,
      ),
    );
    if (r0 <= 4) return;
    ink.stroke(
      arcPts(cx, cy, r0, 0.4, tau + 0.2, 5),
      PenName.pencil,
      const StrokeOpts(
        simple: true,
        alpha: 0.6,
        width: 0.9,
        wobble: 0.8,
        poly: true,
      ),
    );
  });
}
