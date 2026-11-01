import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A pie or donut chart laid out by [layoutPie]: filled slices with their
/// patterns, an inked rim (and hole) and ruled dividers.
///
/// Mirrors `pieRecipe` in `src/lib/ink/recipes/chart-ink/polar.ts`.
final Recipe<PieSpec> chartPieRecipe = defineRecipe<PieSpec>(
  id: 'chart-pie',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, PieSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutPie(spec, size, ctx.calm);
  final PieLayout(:cx, :cy, :radius, :r0) = layout;
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || layout.sectors.isEmpty) {
      drawGhostRing(ink, cx, cy, radius, r0);
      return;
    }
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
  });
}

void _wipe(Ink ink, PieLayout layout, PieSpec spec, bool calm) {
  final PieLayout(:cx, :cy, :radius, :r0, :sectors) = layout;
  final many = sectors.length > 6;
  final perSlice = clamp((160 / sectors.length).floorToDouble(), 10, 60);
  final gapA = math.min(0.03, 1.4 / radius);
  ink.part('fill', () {
    InkOffset? first;
    for (final s in sectors) {
      final poly = sectorPoly(
        cx,
        cy,
        r0,
        radius - 0.5,
        s.a0 + gapA,
        s.a1 - gapA,
        5,
      );
      final off = blobFill(
        ink,
        poly,
        slotKey(spec.slices[s.index].slot),
        alpha: switch (calm) {
          true => 0.8,
          false => 0.88,
        },
        rough: switch (calm) {
          true => 0.3,
          false => 0.6,
        },
      );
      first ??= off;
    }
    return first;
  });
  for (final s in sectors) {
    final sl = spec.slices[s.index];
    if (!spec.patterns || sl.pattern == FillPattern.solid) continue;
    patternFill(
      ink,
      sl.pattern,
      sectorPoly(
        cx,
        cy,
        r0 + 1.5,
        radius - 2,
        s.a0 + gapA * 2,
        s.a1 - gapA * 2,
        6,
      ),
      color: hatchOn(sl.slot),
      maxPulls: perSlice,
      alpha: 0.7,
    );
  }
  final ring = StrokeOpts(
    simple: many || calm,
    wobble: switch (calm) {
      true => 0.2,
      false => 0.7,
    },
    poly: true,
  );
  final a = sectors[0].a0;
  ink.stroke(
    arcPts(cx, cy, radius, a, a + tau + 0.07, 4),
    switch (calm) {
      true => PenName.inkFine,
      false => PenName.ink,
    },
    ring.copyWith(
      width: switch (calm) {
        true => 0.9,
        false => 0.95,
      },
      end: StrokeEnd.flick,
    ),
  );
  if (r0 > 4) {
    ink.stroke(
      arcPts(cx, cy, r0, a + 0.3, a + 0.3 + tau + 0.06, 4),
      PenName.inkFine,
      ring.copyWith(width: 1.05, end: StrokeEnd.flick),
    );
  }
  if (sectors.length == 1) return;
  final divider = ruler.copyWith(simple: true, width: 1.1);
  for (final s in sectors) {
    final p0 = polar(cx, cy, math.max(0, r0 - 1.5), s.a0);
    final p1 = polar(cx, cy, radius + 1.6, s.a0);
    ink.stroke([p0, p1], PenName.inkFine, divider);
  }
}
