import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// An XY chart (bars, lines, areas, scatter and their combinations) laid
/// out by [layoutXY]: highlighter bands, grid, axes and ticks, then the
/// marks wiped in, then the notes and reference lines. Empty and loading
/// charts draw their placeholder.
///
/// Mirrors `xyRecipe` in `src/lib/ink/recipes/chart-ink/xy.ts`.
final Recipe<XYSpec> chartXYRecipe = defineRecipe<XYSpec>(
  id: 'chart-xy',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, XYSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final calm = ctx.calm;
  final layout = layoutXY(spec, size, calm);
  final plot = layout.plot;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready ||
        spec.series.isEmpty ||
        spec.cats.length + layout.dots.length == 0) {
      drawXYState(ink, layout, spec, calm);
      return;
    }
    for (final b in layout.bands) {
      swipeFill(ink, b, layout.horizontal, calm);
    }
    if (spec.grid) drawGrid(ink, layout.gridPx, plot, !layout.horizontal);
    drawAxisLines(
      ink,
      plot,
      x: true,
      y: spec.showY,
      calm: calm,
      zeroY: switch (layout.horizontal) {
        true => null,
        false => layout.basePx,
      },
    );
    drawXYTicks(ink, layout, calm);
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
    if (layout.notes.isNotEmpty || layout.refs.isNotEmpty) {
      drawXYNotes(ink, layout);
    }
  });
}

void _wipe(Ink ink, XYLayout layout, XYSpec spec, bool calm) {
  final rich = !calm && layout.bars.length <= 18 && layout.dots.length <= 60;
  final patterned = layout.bars
      .where(
        (b) => spec.series[b.s].pattern != FillPattern.solid && b.w >= 8,
      )
      .length;
  final maxPulls = clamp((150 / math.max(1, patterned)).floorToDouble(), 9, 60);
  final barPen = switch ((calm, layout.barW >= 24)) {
    (false, true) => PenName.ink,
    _ => PenName.inkFine,
  };
  for (final a in layout.areas) {
    final key = slotKey(spec.series[a.s].slot);
    for (final poly in a.polys) {
      flatFill(ink, poly, key, 0.42);
    }
  }
  _barFills(ink, layout, spec, calm);
  for (final b in layout.bars) {
    _bar(ink, b, layout, spec, rich, maxPulls, barPen);
  }
  final points = layout.lines.fold(
    0,
    (n, l) => n + l.segs.fold(0, (m, s) => m + s.length),
  );
  final heavy = points > 170;
  for (final l in layout.lines) {
    final ser = spec.series[l.s];
    final key = slotKey(ser.slot);
    for (final s in l.segs) {
      switch (s) {
        case [final only]:
          ink.dot(only.x, only.y, 2, PenName.ink, StrokeOpts(color: key));
        case [_, _, ...]:
          drawPolyline(
            ink,
            s,
            switch (spec.patterns && ser.kind == XYKind.line) {
              true => ser.dash,
              false => Dash.solid,
            },
            switch (calm) {
              true => PenName.inkFine,
              false => PenName.ink,
            },
            color: key,
            width: switch (calm) {
              true => 1.05,
              false => 1.2,
            },
            simple: heavy,
          );
        case _:
          break;
      }
    }
  }
  final lean = !rich || layout.dots.length > 40;
  for (final d in layout.dots) {
    _dot(ink, d, spec, calm, lean);
  }
}

void _barFills(Ink ink, XYLayout layout, XYSpec spec, bool calm) {
  final drawn = [
    for (final b in layout.bars)
      if (b.w >= 0.8 && b.h >= 0.8) b,
  ];
  if (drawn.isEmpty) return;
  ink.part('fill', () {
    for (final b in drawn) {
      flatFill(
        ink,
        xyBarShape(b, layout.horizontal),
        slotKey(spec.series[b.s].slot),
        switch (calm) {
          true => 0.88,
          false => 0.95,
        },
      );
    }
    return InkOffset.zero;
  });
}

void _bar(
  Ink ink,
  XYBar b,
  XYLayout layout,
  XYSpec spec,
  bool rich,
  double maxPulls,
  PenName pen,
) {
  final ser = spec.series[b.s];
  if (b.w < 0.8 || b.h < 0.8) return;
  final short = math.min(b.w, b.h);
  final rng = ink.next('bar');
  if (spec.patterns &&
      ser.pattern != FillPattern.solid &&
      b.w >= 8 &&
      b.h >= 8) {
    patternFill(
      ink,
      ser.pattern,
      rectPts(b.x + 1.2, b.y + 1.2, b.w - 2.4, b.h - 2.2),
      color: hatchOn(ser.slot),
      maxPulls: maxPulls,
      alpha: 0.72,
    );
  }
  if (b.w < 6 && !layout.horizontal) return;
  double j() => rng.gauss(0, 0.12);
  final XYBar(:x, :y, :w, :h) = b;
  final pts = switch ((layout.horizontal, b.neg)) {
    (true, true) => <Pt>[
      (x + w, y + j()),
      (x + j(), y + j()),
      (x + j(), y + h + j()),
      (x + w, y + h + j()),
    ],
    (true, false) => <Pt>[
      (x, y + j()),
      (x + w + j(), y + j()),
      (x + w + j(), y + h + j()),
      (x, y + h + j()),
    ],
    (false, true) => <Pt>[
      (x + j(), y),
      (x + j(), y + h + j()),
      (x + w + j(), y + h + j()),
      (x + w + j(), y),
    ],
    (false, false) => <Pt>[
      (x + j(), y + h),
      (x + j(), y + j()),
      (x + w + j(), y + j()),
      (x + w + j(), y + h),
    ],
  };
  ink.stroke(
    pts,
    pen,
    StrokeOpts(
      poly: true,
      round: math.min(3, short * 0.35),
      simple: !rich,
      wobble: 0.15,
      dry: 0,
      end: StrokeEnd.soft,
      start: StrokeStart.soft,
    ),
  );
}

void _dot(Ink ink, XYDot d, XYSpec spec, bool calm, bool lean) {
  final ser = spec.series[d.s];
  final key = slotKey(ser.slot);
  final scatter = ser.kind == XYKind.scatter;
  if (scatter && ser.sizes != null) {
    blobFill(ink, ellipsePoly(d.x, d.y, d.r, d.r, 14), key, alpha: 0.5);
    if (!lean) {
      loop(
        ink,
        d.x,
        d.y,
        d.r,
        d.r,
        pen: PenName.inkFine,
        opts: const StrokeOpts(simple: true, width: 1),
      );
    }
    return;
  }
  final shape = switch (spec.patterns || !scatter) {
    true => ser.marker,
    false => MarkerShape.circle,
  };
  if (scatter && shape == MarkerShape.circle && !lean) {
    blobFill(
      ink,
      ellipsePoly(d.x, d.y, d.r * 0.8, d.r * 0.8, 12),
      key,
      alpha: switch (calm) {
        true => 0.3,
        false => 0.4,
      },
      rough: 0.3,
    );
  }
  drawMarker(
    ink,
    shape,
    d.x,
    d.y,
    switch (scatter) {
      true => math.max(3.2, d.r * 0.78),
      false => d.r,
    },
    color: key,
    rich: !lean && !calm,
    pen: PenName.inkFine,
    width: switch (scatter) {
      true => 1.4,
      false => null,
    },
  );
}
