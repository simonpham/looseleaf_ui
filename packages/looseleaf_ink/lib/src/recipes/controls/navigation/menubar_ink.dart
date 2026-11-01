import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

const int _maxTicks = 72;

/// The menubar: a shaded strip in an inked box with a ruler's ticks along
/// the bottom (a plain pencil box when calm).
///
/// Mirrors `menubarRecipe` in `src/lib/ink/recipes/menubar-ink.ts`.
final Recipe<NoParams> menubarRecipe = defineRecipe<NoParams>(
  id: 'menubar',
  kind: 'bar',
  layers: const [LayerName.rest],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, NoParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final r = clamp(h * 0.09, 2.5, 4.4);
  final inset = clamp(h * 0.06, 1.6, 3);
  final wide = switch (w > 360) {
    true => const StrokeOpts(simple: true),
    false => null,
  };
  ink.layer(LayerName.rest, () {
    wash(
      ink,
      roundRectPoly(inset, inset, w - 2 * inset, h - 2 * inset, r),
      PaintKey.paperShade,
      alpha: 0.85,
      material: Material.wash,
    );
    if (ctx.calm) {
      box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r, opts: wide);
      return;
    }
    const from = 12.0;
    final to = w - 12;
    final count = math.max(
      1,
      JsMath.roundInt((to - from) / math.max(6, (to - from) / _maxTicks)),
    );
    final step = (to - from) / count;
    final y = h - inset - 1.4;
    final d = StringBuffer();
    for (var i = 0; i <= count; i++) {
      final x = from + i * step;
      final major = i % 5 == 0;
      final hh = switch (major) {
        true => 5.2,
        false => 3.0,
      };
      final wd = switch (major) {
        true => 1.0,
        false => 0.8,
      };
      d.write(
        'M${n(x - wd / 2)} ${n(y)}L${n(x + wd / 2)} ${n(y)}'
        'L${n(x + wd / 2)} ${n(y - hh)}L${n(x - wd / 2)} ${n(y - hh)}Z',
      );
    }
    ink.flat(Material.pencil, d.toString(), PaintKey.pencilMark, op: 0.7);
    box(ink, 0, 0, w, h, pen: PenName.inkFine, corner: r, opts: wide);
  });
}
