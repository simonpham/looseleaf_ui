import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The small chart marks: legend swatches and the cursor highlights
/// (column swipe, guide, ring, slice, cell, spoke).
///
/// Mirrors `markRecipe` in `src/lib/ink/recipes/chart-ink/mark.ts`.
final Recipe<MiniParams> chartMarkRecipe = defineRecipe<MiniParams>(
  id: 'chart-mark',
  kind: 'chart',
  layers: const [LayerName.rest],
  pad: 10,
  draw: _draw,
);

void _draw(Ink ink, Box size, MiniParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ink.layer(LayerName.rest, () {
    switch (p) {
      case MiniSwatch():
        _swatch(ink, w, h, p);
      case MiniColumn():
        swipeFill(ink, (x: 1.5, y: 1.5, w: w - 3, h: h - 3), w > h, ctx.calm);
      case MiniGuide():
        _guide(ink, w, h);
      case MiniRing(:final slot):
        loop(
          ink,
          w / 2,
          h / 2,
          w / 2 - 2,
          h / 2 - 2.3,
          pen: PenName.ink,
          opts: StrokeOpts(color: slotKey(slot), width: 0.95, simple: true),
          turns: 1.1,
        );
      case MiniSlice():
        _slice(ink, p);
      case MiniCell():
        blobFill(
          ink,
          rectPts(2, 2, w - 4, h - 4),
          PaintKey.hi,
          alpha: 0.22,
          rough: 0.5,
        );
        box(
          ink,
          1,
          1,
          w - 2,
          h - 2,
          pen: PenName.ink,
          corner: 2,
          opts: const StrokeOpts(simple: true, width: 1),
        );
      case MiniSpoke(:final x1, :final y1, :final x2, :final y2):
        ink.stroke(
          seg(x1, y1, x2, y2, 0.6, 8),
          PenName.hi,
          const StrokeOpts(
            width: 0.7,
            alpha: 0.9,
            start: StrokeStart.soft,
            end: StrokeEnd.soft,
          ),
        );
    }
  });
}

void _swatch(Ink ink, double w, double h, MiniSwatch p) {
  final key = slotKey(p.slot);
  if (p.line ?? false) {
    final y = h / 2;
    drawPolyline(
      ink,
      [(1, y + 0.5), (w * 0.5, y - 0.4), (w - 1, y)],
      p.dash ?? Dash.solid,
      PenName.ink,
      color: key,
      width: 1.15,
      simple: true,
    );
    if (p.marker case final marker? when marker != MarkerShape.none) {
      drawMarker(
        ink,
        marker,
        w / 2,
        y,
        math.min(w, h) * 0.3,
        color: key,
        rich: false,
        pen: PenName.inkFine,
      );
    }
    return;
  }
  final s = math.min(w, h);
  final x0 = (w - s) / 2;
  final y0 = (h - s) / 2;
  final sq = roundRectPoly(
    x0 + 0.8,
    y0 + 0.8,
    s - 1.6,
    s - 1.6,
    math.min(3, s / 4),
  );
  ink.part('fill', () => flatFill(ink, sq, key, 0.95));
  if (p.pattern != FillPattern.solid) {
    patternFill(
      ink,
      p.pattern,
      rectPts(x0 + 2, y0 + 2, s - 4, s - 4),
      color: hatchOn(p.slot),
      maxPulls: 9,
      alpha: 0.75,
      gapK: 0.62,
    );
  }
  final d =
      'M${sq.map((q) => '${JsMath.toFixed(q.x, 2)} ${JsMath.toFixed(q.y, 2)}').join('L')}Z';
  ink.flat(Material.text, d, PaintKey.ink, stroke: PaintKey.ink, sw: 1.1);
}

void _guide(Ink ink, double w, double h) {
  final x = w / 2;
  const gap = 11.0;
  for (var y = 2.0; y < h - 4; y += gap) {
    ink.stroke(
      seg(
        x + JsMath.sin(y) * 0.4,
        y,
        x + JsMath.sin(y + 1) * 0.4,
        math.min(h - 2, y + gap * 0.62),
        0,
        2,
      ),
      PenName.pencil,
      const StrokeOpts(
        simple: true,
        alpha: 0.75,
        width: 0.95,
        start: StrokeStart.soft,
        end: StrokeEnd.soft,
      ),
    );
  }
}

void _slice(Ink ink, MiniSlice p) {
  final MiniSlice(:cx, :cy, :r0, :r1, :a0, :a1) = p;
  blobFill(
    ink,
    sectorPoly(cx, cy, r0, r1, a0, a1, 5),
    PaintKey.hi,
    alpha: 0.26,
    rough: 0.6,
  );
  final edge = [
    ...arcPts(cx, cy, r1, a0, a1, 4),
    ...arcPts(cx, cy, math.max(0.5, r0), a1, a0, 4),
  ];
  ink.stroke(
    [...edge, edge[0], edge[1]],
    PenName.ink,
    const StrokeOpts(
      poly: true,
      round: 1.5,
      width: 1.1,
      simple: true,
      wobble: 0.5,
      end: StrokeEnd.flick,
    ),
  );
}
