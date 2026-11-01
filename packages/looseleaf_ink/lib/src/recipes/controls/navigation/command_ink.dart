import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The command palette's search rule: an inked underline with a pencil
/// echo, and a blue brush line on focus.
///
/// Mirrors `commandInputRecipe` in `src/lib/ink/recipes/command-ink.ts`.
final Recipe<NoParams> commandInputRecipe = defineRecipe<NoParams>(
  id: 'command-input',
  kind: 'rule',
  layers: const [LayerName.rest, LayerName.focus, LayerName.disabled],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, NoParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(
    LayerName.focus,
    (f) => line(
      f,
      2,
      h - 0.5,
      w - 4,
      h - 1.1,
      pen: PenName.blueBrush,
      opts: const StrokeOpts(alpha: 0.95, simple: true),
    ),
  );
  if (ctx.lazyOnly) return;
  ink.layer(LayerName.rest, () {
    if (ctx.calm) {
      line(
        ink,
        0,
        h - 0.5,
        w,
        h - 0.5,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(simple: true),
      );
      return;
    }
    line(
      ink,
      -1,
      h - 0.6,
      w + 1.5,
      h - 1.3,
      pen: PenName.inkFine,
      opts: const StrokeOpts(alpha: 0.9, simple: true),
    );
    line(
      ink,
      6,
      h + 2.6,
      w - 10,
      h + 2.1,
      pen: PenName.pencilFine,
      opts: const StrokeOpts(alpha: 0.55, simple: true),
    );
  });
}
