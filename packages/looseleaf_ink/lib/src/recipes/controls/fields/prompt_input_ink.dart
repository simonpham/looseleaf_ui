import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Prompt input body params.
///
/// Mirrors the params of `promptInputBodyRecipe` in
/// `src/lib/ink/recipes/prompt-input-ink.ts`.
final class PromptInputBodyParams {
  /// Params.
  const PromptInputBodyParams({this.disabled = false});

  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (disabled) 'disabled': true};
}

/// The prompt box's writing line: a pencil rule, a blue brush underline on
/// focus (lazy), a dashed rule when disabled.
///
/// Mirrors `promptInputBodyRecipe` in `src/lib/ink/recipes/prompt-input-ink.ts`.
final Recipe<PromptInputBodyParams> promptInputBodyRecipe =
    defineRecipe<PromptInputBodyParams>(
      id: 'prompt-input-body',
      kind: 'field',
      layers: const [LayerName.rest, LayerName.focus, LayerName.disabled],
      lazy: const [LayerName.focus],
      pad: 8,
      draw: _draw,
    );

void _draw(
  Ink ink,
  Box size,
  PromptInputBodyParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final y = h - 3;
  const x0 = 2.0;
  final x1 = w - 2;
  if (params.disabled) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      final count = math.max(1, JsMath.roundInt((x1 - x0 + 5) / 12));
      final step = (x1 - x0 + 5) / count;
      final opts = ruler.merge(
        const StrokeOpts(simple: true, width: 0.9, color: PaintKey.pencilMark),
      );
      for (var i = 0; i < count; i++) {
        ink.stroke(
          [(x0 + i * step, y), (x0 + i * step + step - 5, y)],
          PenName.pencil,
          opts,
        );
      }
    });
    return;
  }
  ctx.lazy(
    LayerName.focus,
    (f) => underline(
      f,
      x0 - 1,
      y + 0.6,
      x1 - x0 + 2,
      pen: PenName.blueBrush,
      kind: UnderlineKind.single,
    ),
  );
  if (ctx.lazyOnly) return;
  ink.layer(LayerName.rest, () {
    if (ctx.calm) {
      line(
        ink,
        x0,
        y,
        x1,
        y,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(alpha: 0.7, wobble: 0.2),
      );
      return;
    }
    line(ink, x0 - 2, y, x1 + 2, y, pen: PenName.pencil);
  });
}
