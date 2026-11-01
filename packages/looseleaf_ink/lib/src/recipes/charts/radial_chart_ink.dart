import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A radial (ring progress) chart laid out by [layoutRadial]: shaded
/// pencil tracks, then each ring's arc filled and outlined.
///
/// Mirrors `radialRecipe` in `src/lib/ink/recipes/chart-ink/polar.ts`.
final Recipe<RadialSpec> chartRadialRecipe = defineRecipe<RadialSpec>(
  id: 'chart-radial',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, RadialSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutRadial(spec, size, ctx.calm);
  final RadialLayout(:cx, :cy, :arcs) = layout;
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || arcs.isEmpty) {
      drawGhostRing(ink, cx, cy, layout.radius, layout.hole);
      return;
    }
    for (final a in arcs) {
      final track = sectorPoly(
        cx,
        cy,
        a.r - a.t / 2,
        a.r + a.t / 2,
        a.a0,
        a.aEnd,
        5,
      );
      wash(
        ink,
        track,
        PaintKey.paperShade,
        alpha: 0.9,
        shift: 0,
        inset: 0.3,
        wobble: 0.3,
      );
      final rim = [
        ...arcPts(cx, cy, a.r + a.t / 2, a.a0, a.aEnd, 5),
        ...arcPts(cx, cy, a.r - a.t / 2, a.aEnd, a.a0, 5),
      ];
      ink.stroke(
        [...rim, rim[0], rim[1]],
        PenName.pencil,
        const StrokeOpts(
          poly: true,
          round: 1.5,
          simple: true,
          alpha: 0.6,
          width: 0.75,
          wobble: 0.5,
        ),
      );
    }
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
  });
}

void _wipe(Ink ink, RadialLayout layout, RadialSpec spec, bool calm) {
  final RadialLayout(:cx, :cy, :arcs) = layout;
  ink.part('fill', () {
    InkOffset? first;
    for (final a in arcs) {
      if (a.a1 - a.a0 < 0.02) continue;
      final poly = sectorPoly(
        cx,
        cy,
        a.r - a.t / 2 + 0.5,
        a.r + a.t / 2 - 0.5,
        a.a0,
        a.a1,
        4,
      );
      final off = blobFill(
        ink,
        poly,
        slotKey(spec.rings[a.index].slot),
        alpha: switch (calm) {
          true => 0.8,
          false => 0.9,
        },
        rough: 0.4,
      );
      first ??= off;
    }
    return first;
  });
  final outlineOpts = StrokeOpts(
    poly: true,
    simple: calm || arcs.length > 4,
    width: 1.05,
    wobble: 0.5,
    end: StrokeEnd.flick,
    round: 1.5,
  );
  for (final a in arcs) {
    final ring = spec.rings[a.index];
    if (a.a1 - a.a0 < 0.02) continue;
    if (spec.patterns && ring.pattern != FillPattern.solid) {
      patternFill(
        ink,
        ring.pattern,
        sectorPoly(
          cx,
          cy,
          a.r - a.t / 2 + 1.5,
          a.r + a.t / 2 - 1.5,
          a.a0 + 0.02,
          a.a1 - 0.02,
          5,
        ),
        color: hatchOn(ring.slot),
        maxPulls: 34,
        alpha: 0.7,
      );
    }
    final outline = [
      ...arcPts(cx, cy, a.r + a.t / 2, a.a0, a.a1, 4),
      ...arcPts(cx, cy, a.r - a.t / 2, a.a1, a.a0, 4),
    ];
    ink.stroke(
      [...outline, outline[0], outline[1]],
      PenName.inkFine,
      outlineOpts,
    );
  }
}
