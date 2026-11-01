import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';

/// The outline of bar [b], its far end rounded (the left end of a
/// negative horizontal bar, the bottom of a negative column).
///
/// Mirrors `barShape` in `src/lib/ink/recipes/chart-ink/xy.ts`.
List<Pt> xyBarShape(XYBar b, bool horizontal) {
  final r = math.min(3, math.min(b.w, b.h) * 0.35);
  const steps = 5;
  List<Pt> arc(double cx, double cy, double a0) => [
    for (var i = 0; i <= steps; i++)
      () {
        final a = a0 + (i / steps) * (JsMath.pi / 2);
        return (cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r);
      }(),
  ];
  final XYBar(:x, :y, :w, :h) = b;
  return switch ((horizontal, b.neg)) {
    (true, true) => [
      (x + w, y),
      ...arc(x + r, y + r, JsMath.pi * 1.5).reversed,
      ...arc(x + r, y + h - r, JsMath.pi * 0.5).reversed,
      (x + w, y + h),
    ],
    (true, false) => [
      (x, y),
      ...arc(x + w - r, y + r, JsMath.pi * 1.5),
      ...arc(x + w - r, y + h - r, 0),
      (x, y + h),
    ],
    (false, true) => [
      (x, y),
      (x + w, y),
      ...arc(x + w - r, y + h - r, 0),
      ...arc(x + r, y + h - r, JsMath.pi * 0.5),
    ],
    (false, false) => [
      (x, y + h),
      ...arc(x + r, y + r, JsMath.pi),
      ...arc(x + w - r, y + r, JsMath.pi * 1.5),
      (x + w, y + h),
    ],
  };
}

/// The annotations of [layout]: loops, double underlines and arrows in
/// their pens, and dashed reference lines.
///
/// Mirrors `drawNotes` in `src/lib/ink/recipes/chart-ink/xy.ts`.
void drawXYNotes(Ink ink, XYLayout layout) {
  ink.group(GroupAttrs(part: 'note'), () {
    for (final g in layout.notes) {
      if (g.loop case final l?) {
        loop(
          ink,
          l.cx,
          l.cy,
          l.rx,
          l.ry,
          pen: g.pen.std,
          opts: const StrokeOpts(width: 0.9),
        );
      }
      if (g.underline case final u?) {
        underline(
          ink,
          u.x1,
          u.y,
          u.x2 - u.x1,
          pen: g.pen.fine,
          kind: UnderlineKind.double,
        );
      }
      if (g.arrow case final a?) {
        arrow(
          ink,
          a.x1,
          a.y1,
          a.x2,
          a.y2,
          pen: g.pen.fine,
          curve: 0.22,
          headLen: 7,
          opts: const StrokeOpts(width: 1.05),
        );
      }
    }
    final dashOpts = ruler.copyWith(simple: true, alpha: 0.85, width: 0.95);
    for (final r in layout.refs) {
      final len = JsMath.hypot(r.x2 - r.x1, r.y2 - r.y1);
      final pen = switch (r.pen.fine) {
        PenName.redfeltFine => PenName.red,
        _ => PenName.pencil,
      };
      for (var d = 0.0; d < len; d += 15) {
        final a = d / len;
        final e = math.min(len, d + 9) / len;
        ink.stroke(
          [
            (r.x1 + (r.x2 - r.x1) * a, r.y1 + (r.y2 - r.y1) * a),
            (r.x1 + (r.x2 - r.x1) * e, r.y1 + (r.y2 - r.y1) * e),
          ],
          pen,
          dashOpts,
        );
      }
    }
  });
}

/// The tick marks under the category (or value) labels and beside the
/// value labels of [layout].
///
/// Mirrors `drawTicks` in `src/lib/ink/recipes/chart-ink/xy.ts`.
void drawXYTicks(Ink ink, XYLayout layout, bool calm) {
  final (:x0, :x1, :y1, y0: _) = layout.plot;
  final reach = switch (calm) {
    true => 3.5,
    false => 4.6,
  };
  void along(ChartLabel l, bool bottom) {
    final rng = ink.next('tick');
    final j = rng.gauss(0, 0.25);
    if (bottom) {
      ink.stroke(
        [(l.x + j, y1 - 1.2), (l.x + rng.gauss(0, 0.2), y1 + reach)],
        PenName.inkFine,
        const StrokeOpts(
          simple: true,
          width: 0.9,
          alpha: 0.85,
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          wobble: 0.3,
        ),
      );
      return;
    }
    ink.stroke(
      [(x0 + 1.2, l.y + j), (x0 - reach, l.y + rng.gauss(0, 0.2))],
      PenName.pencil,
      const StrokeOpts(
        simple: true,
        width: 0.95,
        alpha: 0.85,
        start: StrokeStart.soft,
        end: StrokeEnd.flick,
        wobble: 0.3,
      ),
    );
  }

  for (final l in layout.labels) {
    if (l.x < x0 - 60 || l.x > x1 + 60) continue;
    switch ((layout.horizontal, l.role)) {
      case (true, LabelRole.y) || (false, LabelRole.x):
        along(l, true);
      case (true, LabelRole.cat) || (false, LabelRole.y):
        along(l, false);
      case _:
        break;
    }
  }
}

/// The axes of an empty chart, with a pulsing row of dashed ghost bars
/// while [spec] is loading or a pencil squiggle when there is no data.
///
/// Mirrors `drawState` in `src/lib/ink/recipes/chart-ink/xy.ts`.
void drawXYState(Ink ink, XYLayout layout, XYSpec spec, bool calm) {
  final (:x0, :y0, :x1, :y1) = layout.plot;
  drawAxisLines(ink, layout.plot, x: true, y: true, calm: calm);
  if (spec.state == ChartState.loading) {
    ink.group(GroupAttrs(part: 'pulse'), () {
      const hs = [0.26, 0.42, 0.32, 0.52, 0.38, 0.46];
      final bw = math.min(46.0, (x1 - x0) / (hs.length * 1.7));
      final step = (x1 - x0) / hs.length;
      for (final (i, k) in hs.indexed) {
        final hh = (y1 - y0) * k;
        dashedBox(
          ink,
          x0 + step * (i + 0.5) - bw / 2,
          y1 - hh,
          bw,
          hh,
          r: 2,
          pen: PenName.pencil,
          opts: const StrokeOpts(alpha: 0.7),
        );
      }
    });
    return;
  }
  squiggle(
    ink,
    x0 + 12,
    y0 + (y1 - y0) * 0.68,
    math.max(20, x1 - x0 - 24),
    pen: PenName.pencil,
    h: 14,
    amp: 1.4,
    wl: 1.3,
    opts: const StrokeOpts(alpha: 0.55),
  );
}
