import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/card/card.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The bottom of a card: a row of [children], centred on the cross axis and
/// laid out by [mainAxisAlignment]. [divider] rules it off from the content
/// with a drawn [rule] and 24 px of room (upstream's `border-t`).
///
/// Mirrors `CardFooter` in upstream `src/components/ui/card.tsx`.
class CardFooter extends StatelessWidget {
  const CardFooter({
    super.key,
    this.divider = false,
    this.rule = CardRuleStyle.pencil,
    this.seed,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.spacing = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.d24),
    required this.children,
  });

  /// Draws a rule over the footer.
  final bool divider;

  /// How the rule is drawn.
  final CardRuleStyle rule;

  /// Pins the rule's drawing.
  final String? seed;

  /// How the children spread along the row.
  final MainAxisAlignment mainAxisAlignment;

  /// The gap between children.
  final double spacing;

  /// The padding around the footer (`px-6`).
  final EdgeInsetsGeometry padding;

  /// The footer's contents, usually buttons.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: padding.add(
        EdgeInsets.only(
          top: switch (divider) {
            true => Spacing.d24,
            false => 0,
          },
        ),
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        spacing: spacing,
        children: children,
      ),
    );
    if (!divider) return padded;
    return CardRule(
      edge: CardRuleEdge.top,
      style: rule,
      seed: seed,
      child: padded,
    );
  }
}
