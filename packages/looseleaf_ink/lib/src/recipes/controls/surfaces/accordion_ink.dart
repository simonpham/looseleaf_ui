import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The pencil rule between accordion items.
///
/// Mirrors `accordionRuleRecipe` in `src/lib/ink/recipes/accordion-ink.ts`.
final Recipe<NoParams> accordionRuleRecipe = defineRecipe<NoParams>(
  id: 'accordion-rule',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 8,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    final y = h / 2;
    final x0 = math.min(6, w * 0.03).toDouble();
    ink.layer(LayerName.rest, () {
      if (ctx.calm) {
        line(
          ink,
          x0,
          y,
          w - x0,
          y,
          pen: PenName.pencilFine,
          opts: const StrokeOpts(alpha: 0.7, wobble: 0.2),
        );
        return;
      }
      line(ink, x0, y, w - x0, y, pen: PenName.pencil);
    });
  },
);

/// Accordion trigger params.
///
/// Mirrors the params of `accordionTriggerRecipe` in
/// `src/lib/ink/recipes/accordion-ink.ts`.
final class AccordionTriggerParams {
  /// Params.
  const AccordionTriggerParams({this.disabled = false});

  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (disabled) 'disabled': true};
}

/// The accordion trigger row: a highlighter swipe on hover and a focus ring,
/// both lazy; nothing when disabled.
///
/// Mirrors `accordionTriggerRecipe` in `src/lib/ink/recipes/accordion-ink.ts`.
final Recipe<AccordionTriggerParams> accordionTriggerRecipe =
    defineRecipe<AccordionTriggerParams>(
      id: 'accordion-trigger',
      kind: 'row',
      layers: const [LayerName.hover, LayerName.focus],
      lazy: const [LayerName.hover, LayerName.focus],
      pad: 12,
      draw: (_, size, params, ctx) {
        final Box(:w, :h) = size;
        if (params.disabled) return;
        ctx
          ..lazy(LayerName.hover, (s) {
            final inset = math.min(4, w * 0.02).toDouble();
            s.part(
              'swipe',
              () => highlight(
                s,
                inset,
                h * 0.2,
                w - inset * 2 - 6,
                h * 0.6,
                k: 1,
              ),
              Material.hl,
            );
          })
          ..lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 4));
      },
    );
