import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The rule under a code block's header: a dashed pencil line, a fine
/// solid one when calm.
///
/// Mirrors `codeRuleRecipe` in `src/lib/ink/recipes/code-block-ink.ts`.
final Recipe<NoParams> codeRuleRecipe = defineRecipe<NoParams>(
  id: 'code-block-rule',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 6,
  draw: _drawRule,
);

void _drawRule(
  Ink ink,
  Box size,
  NoParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final y = h - 1.5;
  final x0 = math.min(14, w * 0.04).toDouble();
  final x1 = w - x0;
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
    const dash = 7;
    const gap = 4.5;
    for (var x = x0; x < x1 - dash; x += dash + gap) {
      ink.stroke(
        [(x, y), (x + dash, y)],
        PenName.pencil,
        const StrokeOpts(
          simple: true,
          raw: true,
          poly: true,
          start: StrokeStart.soft,
          end: StrokeEnd.soft,
          width: 0.9,
        ),
      );
    }
  });
}

/// The code block body: only a lazy focus ring.
///
/// Mirrors `codeBodyRecipe` in `src/lib/ink/recipes/code-block-ink.ts`.
final Recipe<NoParams> codeBodyRecipe = defineRecipe<NoParams>(
  id: 'code-block-body',
  kind: 'code',
  layers: const [LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, 2, 2, w - 4, h - 4, r: 3),
    );
  },
);
