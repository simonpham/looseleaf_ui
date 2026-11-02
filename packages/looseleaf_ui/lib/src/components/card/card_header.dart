import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/card/card.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The top of a card: its [CardTitle] and [CardDescription] stacked 8 px
/// apart, with a [CardAction] (when one is among [children]) at the top end.
/// [divider] rules it off from the content with a drawn [rule] and 24 px of
/// room (upstream's `border-b`).
///
/// [crossAxisAlignment] [CrossAxisAlignment.center] centres the title and
/// description and their lines (upstream `justify-items-center
/// text-center`), as sign-in cards do.
///
/// Mirrors `CardHeader` in upstream `src/components/ui/card.tsx`.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    this.divider = false,
    this.rule = CardRuleStyle.pencil,
    this.seed,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.d24),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  /// Draws a rule under the header.
  final bool divider;

  /// How the rule is drawn.
  final CardRuleStyle rule;

  /// Pins the rule's drawing.
  final String? seed;

  /// The padding around the header (`px-6`).
  final EdgeInsetsGeometry padding;

  /// How the title and description line up: start, or centred with
  /// centred lines.
  final CrossAxisAlignment crossAxisAlignment;

  /// The title, description and an optional [CardAction].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final action = children.whereType<CardAction>().firstOrNull;
    final centered = crossAxisAlignment == CrossAxisAlignment.center;
    final column = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        for (final child in children)
          if (child is! CardAction) child,
      ],
    );
    final Widget text = switch (centered) {
      true => DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        child: column,
      ),
      false => column,
    };
    final Widget body = switch (action) {
      null => text,
      final end => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Expanded(child: text),
          end,
        ],
      ),
    };
    final padded = Padding(
      padding: padding.add(
        EdgeInsets.only(
          bottom: switch (divider) {
            true => Spacing.d24,
            false => 0,
          },
        ),
      ),
      child: body,
    );
    if (!divider) return padded;
    return CardRule(
      edge: CardRuleEdge.bottom,
      style: rule,
      seed: seed,
      child: padded,
    );
  }
}
