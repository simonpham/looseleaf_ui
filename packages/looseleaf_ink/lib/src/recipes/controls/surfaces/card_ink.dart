import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The card edge a rule sits on.
enum CardRuleEdge { top, bottom }

/// How a card rule is drawn.
///
/// Mirrors `CardRuleStyle` in `src/lib/ink/recipes/card-ink.ts`.
enum CardRuleStyle { pencil, dashed, wavy }

/// Card rule params.
///
/// Mirrors `CardRuleParams` in `src/lib/ink/recipes/card-ink.ts`.
final class CardRuleParams {
  /// Params.
  const CardRuleParams({required this.edge, required this.style});

  final CardRuleEdge edge;
  final CardRuleStyle style;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'edge': edge.name, 'style': style.name};
}

/// A rule under a card header or over its footer: pencil, dashed or wavy.
///
/// Mirrors `cardRuleRecipe` in `src/lib/ink/recipes/card-ink.ts`.
final Recipe<CardRuleParams> cardRuleRecipe = defineRecipe<CardRuleParams>(
  id: 'card-rule',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 8,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final y = switch (params.edge) {
      CardRuleEdge.bottom => h - 1,
      CardRuleEdge.top => 1.0,
    };
    final x0 = math.min(14, w * 0.05).toDouble();
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
      switch (params.style) {
        case CardRuleStyle.dashed:
          final r = ink.next('dash');
          const dash = 8;
          const gap = 5.5;
          for (
            var x = x0 + r.range(0, 3);
            x < x1 - dash;
            x += dash + gap + r.gauss(0, 0.6)
          ) {
            final yy = y + r.gauss(0, 0.45) - ((x - x0) / (x1 - x0)) * 0.9;
            ink.stroke(
              [(x, yy), (x + dash * r.range(0.85, 1.1), yy + r.gauss(0, 0.35))],
              PenName.pencil,
              const StrokeOpts(
                simple: true,
                wobble: 0.3,
                start: StrokeStart.soft,
                end: StrokeEnd.soft,
                width: 0.9,
              ),
            );
          }
        case CardRuleStyle.wavy:
          squiggle(
            ink,
            x0,
            y,
            x1 - x0,
            pen: PenName.pencilFine,
            h: 3,
            amp: 1.3,
            wl: 15,
          );
        case CardRuleStyle.pencil:
          line(ink, x0, y, x1, y, pen: PenName.pencil);
      }
    });
  },
);
