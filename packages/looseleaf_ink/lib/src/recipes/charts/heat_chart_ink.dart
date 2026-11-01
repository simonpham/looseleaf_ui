import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/recipes/charts/chart_recipes.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The marker opacity of heat [level] out of [count] levels; level 0 is
/// the faint pencil wash.
///
/// Mirrors `heatAlpha` in `src/lib/ink/recipes/chart-ink/mini.ts`.
double heatAlpha(int level, int count) {
  if (level <= 0) return 0.16;
  return 0.26 + (0.68 * (level - 1)) / math.max(1, count - 2);
}

/// A heatmap (calendar or grid) laid out by [layoutHeat]: rough marker
/// squares per level and an optional less-to-more legend; a pulsing grid
/// of washes while empty or loading.
///
/// Mirrors `heatRecipe` in `src/lib/ink/recipes/chart-ink/mini.ts`.
final Recipe<HeatSpec> chartHeatRecipe = defineRecipe<HeatSpec>(
  id: 'chart-heat',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, HeatSpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutHeat(spec, size, ctx.calm);
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || layout.cells.isEmpty) {
      ink.group(GroupAttrs(part: 'pulse'), () {
        final d = StringBuffer();
        for (var i = 0; i < spec.cols * spec.rows; i++) {
          d.write(
            roughSquare(
              ink,
              layout.gx + (i % spec.cols) * layout.cs,
              layout.gy + (i ~/ spec.cols) * layout.cs,
              layout.cell,
              layout.cell,
              0.3,
            ),
          );
        }
        ink.flat(Material.wash, '$d', PaintKey.pencilMark, op: 0.2);
      });
      return;
    }
    final amt = switch (calm || layout.cell < 6) {
      true => 0.0,
      false => clamp(layout.cell * 0.05, 0.2, 0.6),
    };
    ink.group(
      GroupAttrs(part: 'wipe'),
      () => _wipe(ink, layout, spec, calm, amt),
    );
  });
}

void _wipe(Ink ink, HeatLayout layout, HeatSpec spec, bool calm, double amt) {
  final key = slotKey(spec.slot);
  final count = spec.levelCount;
  final byLevel = List.generate(count, (_) => StringBuffer());
  for (final c in layout.cells) {
    final square = roughSquare(ink, c.x, c.y, layout.cell, layout.cell, amt);
    final lv = math.min(count - 1, c.level);
    if (lv >= 0) byLevel[lv].write(square);
  }
  for (final (lv, d) in byLevel.indexed) {
    if (d.isEmpty) continue;
    if (lv == 0) {
      ink.flat(Material.wash, '$d', PaintKey.pencilMark, op: 0.2);
      continue;
    }
    final alpha = heatAlpha(lv, count);
    ink.flat(
      Material.marker,
      '$d',
      key,
      op: switch (calm) {
        true => alpha * 0.9,
        false => alpha,
      },
    );
  }
  final legend = layout.legend;
  if (legend == null) return;
  final per = [
    for (var lv = 0; lv < count; lv++)
      roughSquare(
        ink,
        legend.x + lv * (legend.cell + 3),
        legend.y,
        legend.cell,
        legend.cell,
        amt,
      ),
  ];
  for (final (lv, d) in per.indexed) {
    if (lv == 0) {
      ink.flat(Material.wash, d, PaintKey.pencilMark, op: 0.2);
      continue;
    }
    ink.flat(Material.marker, d, key, op: heatAlpha(lv, count));
  }
}
