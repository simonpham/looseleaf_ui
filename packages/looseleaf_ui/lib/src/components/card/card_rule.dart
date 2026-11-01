import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Draws a card divider along the [edge] of [child]'s box: a pencil,
/// dashed or wavy rule inset from the sides (a fine pencil line when calm).
/// [CardHeader] and [CardFooter] use it for their `border-b` / `border-t`.
///
/// Mirrors `useDivider` in upstream `src/components/ui/card.tsx`.
class CardRule extends StatefulWidget {
  const CardRule({
    super.key,
    required this.edge,
    this.style = CardRuleStyle.pencil,
    this.seed,
    required this.child,
  });

  /// The side the rule runs along.
  final CardRuleEdge edge;

  /// How the rule is drawn.
  final CardRuleStyle style;

  /// Pins the drawing.
  final String? seed;

  /// The part the rule borders.
  final Widget child;

  @override
  State<CardRule> createState() => _CardRuleState();
}

class _CardRuleState extends State<CardRule> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = CardRuleParams(edge: widget.edge, style: widget.style);
    return InkSurface(
      source: RecipeInkSource(cardRuleRecipe, params, json: params.toJson()),
      seed: inkSeed(widget.seed),
      child: widget.child,
    );
  }
}
