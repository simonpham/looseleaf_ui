import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Flip card trigger recipe params.
///
/// Mirrors `FlipTriggerParams` in `src/lib/ink/recipes/flip-card-ink.ts`.
final class FlipTriggerParams {
  /// Params.
  const FlipTriggerParams({this.hint});

  /// Draws the curved "flip me" arrow in the corner; defaults to true.
  final bool? hint;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (hint case final bool v) 'hint': v};
}

/// The flip card's trigger: a pencil arrow in the bottom corner that inks
/// in on hover, and a lazy focus ring.
///
/// Mirrors `flipTriggerRecipe` in `src/lib/ink/recipes/flip-card-ink.ts`.
final Recipe<FlipTriggerParams> flipTriggerRecipe =
    defineRecipe<FlipTriggerParams>(
      id: 'flip-card-trigger',
      kind: 'flip-card-trigger',
      layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
      lazy: const [LayerName.focus],
      pad: 12,
      draw: _draw,
    );

void _draw(Ink ink, Box size, FlipTriggerParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, -1, -1, w + 2, h + 2, r: 4));
  if (ctx.lazyOnly || !(params.hint ?? true)) return;
  final x = w - 20, y = h - 20;
  ink
    ..layer(LayerName.rest, () {
      arrow(
        ink,
        x - 16,
        y + 10,
        x + 4,
        y - 12,
        pen: PenName.pencil,
        head: ArrowHead.v,
        curve: 0.35,
        headLen: 8,
        opts: const StrokeOpts(alpha: 0.9, width: 1.2),
      );
    })
    ..layer(LayerName.hover, () {
      arrow(
        ink,
        x - 16,
        y + 10,
        x + 4,
        y - 12,
        pen: PenName.ink,
        head: ArrowHead.v,
        curve: 0.35,
        headLen: 8,
      );
      arrow(
        ink,
        x - 30,
        y + 14,
        x - 15,
        y + 2,
        pen: PenName.inkFine,
        head: ArrowHead.none,
        curve: 0.3,
        opts: const StrokeOpts(alpha: 0.7),
      );
    });
}
