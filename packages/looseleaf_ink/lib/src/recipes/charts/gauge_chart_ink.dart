import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A gauge laid out by [layoutGauge]: a shaded track or coloured zones,
/// the inked arc with ruled ends and ticks, and a red needle.
///
/// Mirrors `gaugeRecipe` in `src/lib/ink/recipes/chart-ink/polar.ts`.
final Recipe<GaugeSpec> chartGaugeRecipe = defineRecipe<GaugeSpec>(
  id: 'chart-gauge',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, GaugeSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutGauge(spec, size, ctx.calm);
  final GaugeLayout(:cx, :cy, :radius, :t, :a0, :a1) = layout;
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready) {
      ink.group(
        GroupAttrs(part: 'pulse'),
        () => ink.stroke(
          arcPts(cx, cy, radius - t / 2, a0, a1, 5),
          PenName.pencil,
          const StrokeOpts(
            simple: true,
            alpha: 0.7,
            width: 0.9,
            wobble: 0.8,
            poly: true,
          ),
        ),
      );
      return;
    }
    final zoned = layout.zones.isNotEmpty;
    final track = sectorPoly(cx, cy, radius - t, radius, a0, a1, 4);
    if (!zoned) {
      wash(
        ink,
        track,
        PaintKey.paperShade,
        alpha: 0.95,
        shift: switch (calm) {
          true => 0,
          false => 0.8,
        },
        inset: 0.3,
        wobble: 0.3,
      );
    }
    ink.group(GroupAttrs(part: 'wipe'), () => _wipe(ink, layout, spec, calm));
  });
}

void _fills(Ink ink, GaugeLayout layout, GaugeSpec spec, bool calm) {
  final GaugeLayout(:cx, :cy, :radius, :t, :a0, :av, :zones) = layout;
  if (zones.isEmpty) {
    if (av - a0 <= 0.02) return;
    ink.part(
      'fill',
      () => blobFill(
        ink,
        sectorPoly(cx, cy, radius - t + 0.6, radius - 0.6, a0, av, 4),
        slotKey(0),
        alpha: 0.9,
        rough: 0.4,
      ),
    );
    return;
  }
  ink.part('fill', () {
    InkOffset? first;
    for (final z in zones) {
      final off = blobFill(
        ink,
        sectorPoly(cx, cy, radius - t + 0.6, radius - 0.6, z.a0, z.a1, 4),
        slotKey(z.slot),
        alpha: switch (calm) {
          true => 0.8,
          false => 0.88,
        },
        rough: 0.4,
      );
      first ??= off;
    }
    return first;
  });
  for (final z in zones) {
    if (!spec.patterns || z.pattern == FillPattern.solid) continue;
    patternFill(
      ink,
      z.pattern,
      sectorPoly(
        cx,
        cy,
        radius - t + 2,
        radius - 2,
        z.a0 + 0.02,
        z.a1 - 0.02,
        5,
      ),
      color: hatchOn(z.slot),
      maxPulls: 30,
      alpha: 0.7,
    );
  }
}

void _wipe(Ink ink, GaugeLayout layout, GaugeSpec spec, bool calm) {
  final GaugeLayout(:cx, :cy, :radius, :t, :a0, :a1, :av, :zones) = layout;
  _fills(ink, layout, spec, calm);
  final open = StrokeOpts(
    poly: true,
    wobble: switch (calm) {
      true => 0.2,
      false => 0.7,
    },
    width: switch (calm) {
      true => 0.9,
      false => 1,
    },
    end: StrokeEnd.flick,
    simple: calm,
  );
  ink
    ..stroke(
      arcPts(cx, cy, radius, a0 - 0.02, a1 + 0.03, 4),
      switch (calm) {
        true => PenName.inkFine,
        false => PenName.ink,
      },
      open,
    )
    ..stroke(
      arcPts(cx, cy, radius - t, a0 - 0.01, a1 + 0.02, 4),
      PenName.inkFine,
      open.copyWith(width: 1.05),
    );
  final edge = ruler.copyWith(simple: true, width: 1.05);
  for (final a in [a0, a1, for (final z in zones) z.a1]) {
    final p0 = polar(cx, cy, radius - t - 2, a);
    final p1 = polar(cx, cy, radius + 2, a);
    ink.stroke([p0, p1], PenName.inkFine, edge);
  }
  if (!calm) {
    final tick = ruler.copyWith(simple: true, alpha: 0.6, width: 0.8);
    for (final a in layout.tickAngles) {
      final p0 = polar(cx, cy, radius + 4, a);
      final p1 = polar(cx, cy, radius + 9, a);
      ink.stroke([p0, p1], PenName.pencil, tick);
    }
  }
  if (zones.isEmpty && spec.zones.isNotEmpty) return;
  final tip = polar(cx, cy, radius - t * 0.2, av);
  final base = polar(cx, cy, 6, av + JsMath.pi);
  ink.stroke(
    [base, tip],
    PenName.redfelt,
    ruler.copyWith(
      width: switch (calm) {
        true => 1,
        false => 1.3,
      },
      simple: calm,
    ),
  );
  loop(
    ink,
    cx,
    cy,
    5.4,
    5.2,
    pen: PenName.inkFine,
    opts: const StrokeOpts(simple: true, width: 1),
  );
  ink.dot(cx, cy, 2.4);
}
