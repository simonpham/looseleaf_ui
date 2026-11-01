import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A sparkline laid out by [layoutSpark]: a line, a washed area or marker
/// bars, with optional pencil dots on the extremes and a red end dot.
///
/// Mirrors `sparkRecipe` in `src/lib/ink/recipes/chart-ink/mini.ts`.
final Recipe<SparkSpec> chartSparkRecipe = defineRecipe<SparkSpec>(
  id: 'chart-spark',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 8,
  draw: _draw,
);

void _draw(Ink ink, Box size, SparkSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 4));
  if (ctx.lazyOnly) return;
  final layout = layoutSpark(spec, size);
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || layout.pts.every((p) => p == null)) {
      line(
        ink,
        4,
        h / 2,
        w - 4,
        h / 2 - 0.6,
        pen: PenName.pencil,
        opts: const StrokeOpts(simple: true, alpha: 0.6, width: 0.9),
      );
      return;
    }
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
  });
}

void _wipe(Ink ink, SparkLayout layout, SparkSpec spec, bool calm) {
  final key = slotKey(spec.slot);
  if (spec.variant == SparkVariant.bar) {
    final d = StringBuffer();
    for (final b in layout.bars) {
      d.write(
        roughSquare(
          ink,
          b.x,
          b.y,
          b.w,
          b.h,
          switch (calm) {
            true => 0,
            false => 0.35,
          },
        ),
      );
    }
    ink.flat(
      Material.marker,
      '$d',
      key,
      op: switch (calm) {
        true => 0.8,
        false => 0.9,
      },
    );
    return;
  }
  if (spec.variant == SparkVariant.area) {
    for (final s in layout.segs) {
      if (s.length < 2) continue;
      wash(
        ink,
        [...s, (s[s.length - 1].x, layout.baseY), (s[0].x, layout.baseY)],
        key,
        alpha: 0.28,
        shift: switch (calm) {
          true => 0,
          false => 0.9,
        },
        inset: 0.3,
        wobble: 0.3,
      );
    }
  }
  for (final s in layout.segs) {
    if (s.length < 2) continue;
    drawPolyline(
      ink,
      s,
      Dash.solid,
      switch (calm) {
        true => PenName.inkFine,
        false => PenName.ink,
      },
      color: key,
      width: switch (calm) {
        true => 1,
        false => 1.05,
      },
      simple: true,
    );
  }
  if (spec.extremes) {
    for (final p in [layout.minPt, layout.maxPt]) {
      if (p == null) continue;
      ink.dot(
        p.x,
        p.y,
        1.9,
        PenName.ink,
        const StrokeOpts(color: PaintKey.pencil),
      );
    }
  }
  if (layout.last case final last? when spec.ends) {
    ink.dot(
      last.x,
      last.y,
      switch (calm) {
        true => 2.2,
        false => 2.7,
      },
      PenName.redfelt,
    );
  }
}
