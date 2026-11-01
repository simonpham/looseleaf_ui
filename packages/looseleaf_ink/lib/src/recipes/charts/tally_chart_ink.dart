import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A tally chart laid out by [layoutTally]: a pencil rule under each row
/// and its count in gates of five.
///
/// Mirrors `tallyRecipe` in `src/lib/ink/recipes/chart-ink/mini.ts`.
final Recipe<TallySpec> chartTallyRecipe = defineRecipe<TallySpec>(
  id: 'chart-tally',
  kind: 'chart',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, TallySpec spec, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  if (ctx.lazyOnly) return;
  final layout = layoutTally(spec, size, ctx.calm);
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (spec.state != ChartState.ready || layout.rows.isEmpty) {
      line(
        ink,
        8,
        h / 2,
        w - 8,
        h / 2 - 0.6,
        pen: PenName.pencil,
        opts: const StrokeOpts(simple: true, alpha: 0.6, width: 0.9),
      );
      return;
    }
    final rule = StrokeOpts(
      simple: true,
      alpha: switch (calm) {
        true => 0.3,
        false => 0.38,
      },
      width: 0.75,
      wobble: switch (calm) {
        true => 0.2,
        false => 1,
      },
    );
    final area = layout.markArea;
    for (final r in layout.rows) {
      line(
        ink,
        area.x0 - 6,
        r.y + r.gh + 4,
        area.x1,
        r.y + r.gh + 3.4,
        pen: PenName.pencil,
        opts: rule,
      );
    }
    ink.group(GroupAttrs(part: 'wipe'), () {
      final heavy = layout.rows.fold(0, (n, r) => n + r.marks) > 60;
      for (final r in layout.rows) {
        final key = slotKey(spec.rows[r.index].slot);
        final t = tallyLines(ink.next('tally'), r.x, r.y, r.marks, r.gh);
        ink.lines(
          t.lines,
          switch (calm) {
            true => PenName.inkFine,
            false => PenName.ink,
          },
          StrokeOpts(
            color: key,
            simple: heavy || calm,
            width: switch (calm) {
              true => 1.1,
              false => 1.25,
            },
          ),
        );
      }
    });
  });
}
