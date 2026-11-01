import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A radar chart laid out by [layoutRadar]: ruled rings and spokes, then
/// each series washed in, outlined and dotted.
///
/// Mirrors `radarRecipe` in `src/lib/ink/recipes/chart-ink/polar.ts`.
final Recipe<RadarSpec> chartRadarRecipe = defineRecipe<RadarSpec>(
  id: 'chart-radar',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, RadarSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutRadar(spec, size, ctx.calm);
  final RadarLayout(:cx, :cy, :radius, :rings, :axesAngles) = layout;
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || spec.axes.length < 3) {
      drawGhostRing(ink, cx, cy, radius, 0);
      return;
    }
    for (final (k, r) in rings.indexed) {
      final ring = [for (final a in axesAngles) polar(cx, cy, r, a)];
      final opts = ruler.copyWith(
        simple: true,
        alpha: switch (k == rings.length - 1) {
          true => 0.75,
          false => 0.45,
        },
        width: switch (calm) {
          true => 0.75,
          false => 0.8,
        },
      );
      for (final (i, p) in ring.indexed) {
        ink.stroke([p, ring[(i + 1) % ring.length]], PenName.pencil, opts);
      }
    }
    final spoke = ruler.copyWith(simple: true, alpha: 0.5, width: 0.75);
    for (final a in axesAngles) {
      ink.stroke([(cx, cy), polar(cx, cy, radius, a)], PenName.pencil, spoke);
    }
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
  });
}

void _wipe(Ink ink, RadarLayout layout, RadarSpec spec, bool calm) {
  final RadarLayout(:cx, :cy, :axesAngles, :polys) = layout;
  final n = spec.axes.length;
  for (final (k, s) in spec.series.indexed) {
    final key = slotKey(s.slot);
    final pts = [
      for (final (i, p) in polys[k].indexed)
        p ?? polar(cx, cy, 0, axesAngles[i]),
    ];
    if (spec.fill) {
      wash(
        ink,
        pts,
        key,
        alpha: switch (calm) {
          true => 0.16,
          false => 0.3,
        },
        shift: switch (calm) {
          true => 0,
          false => 1.4,
        },
        inset: 0.4,
        wobble: switch (calm) {
          true => 0.2,
          false => 0.5,
        },
      );
      if (spec.patterns && s.pattern != FillPattern.solid) {
        patternFill(
          ink,
          s.pattern,
          pts,
          color: key,
          maxPulls: 46,
          alpha: 0.55,
          gapK: 1.2,
        );
      }
    }
    ink.stroke(
      [...pts, pts[0], pts[1]],
      PenName.ink,
      StrokeOpts(
        color: key,
        poly: true,
        round: 1.4,
        width: switch (calm) {
          true => 1,
          false => 1.15,
        },
        wobble: 0.5,
        simple: calm || spec.series.length > 3,
        end: StrokeEnd.flick,
      ),
    );
    if (!spec.dots) continue;
    for (final (i, p) in pts.indexed) {
      if (polys[k][i] == null) continue;
      drawMarker(
        ink,
        switch (spec.patterns) {
          true => s.marker,
          false => MarkerShape.circle,
        },
        p.x,
        p.y,
        3.4,
        color: key,
        rich: !calm && n * spec.series.length <= 40,
        pen: PenName.inkFine,
      );
    }
  }
}
