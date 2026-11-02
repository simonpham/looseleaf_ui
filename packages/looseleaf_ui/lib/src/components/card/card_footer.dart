import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/card/card.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The bottom of a card: a row of [children], centred on the cross axis and
/// laid out by [mainAxisAlignment]. [divider] rules it off from the content
/// with a drawn [rule] and 24 px of room (upstream's `border-t`).
///
/// [wrap] breaks the row onto more lines when it runs out of room
/// (upstream `flex-wrap`); [direction] [Axis.vertical] stacks the children
/// instead (upstream `flex-col`), aligned by [crossAxisAlignment]
/// (`items-start`, `items-stretch`).
///
/// ```dart
/// CardFooter(
///   direction: Axis.vertical,
///   crossAxisAlignment: CrossAxisAlignment.start,
///   spacing: Spacing.d8,
///   children: [Text('Trending up by 5.2%'), Text('January to June')],
/// )
/// ```
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
    this.direction = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrap = false,
    this.runSpacing,
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

  /// A row ([Axis.horizontal]) or a stack ([Axis.vertical], upstream
  /// `flex-col`).
  final Axis direction;

  /// How the children line up across [direction] (upstream `items-*`).
  final CrossAxisAlignment crossAxisAlignment;

  /// Lets a row break onto more lines instead of overflowing (upstream
  /// `flex-wrap`).
  final bool wrap;

  /// The gap between wrapped lines; [spacing] when null (upstream
  /// `gap-y-*`).
  final double? runSpacing;

  /// The padding around the footer (`px-6`).
  final EdgeInsetsGeometry padding;

  /// The footer's contents, usually buttons.
  final List<Widget> children;

  WrapAlignment get _wrapAlignment => switch (mainAxisAlignment) {
    MainAxisAlignment.start => WrapAlignment.start,
    MainAxisAlignment.end => WrapAlignment.end,
    MainAxisAlignment.center => WrapAlignment.center,
    MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
    MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
    MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
  };

  WrapCrossAlignment get _wrapCrossAlignment => switch (crossAxisAlignment) {
    CrossAxisAlignment.start => WrapCrossAlignment.start,
    CrossAxisAlignment.end => WrapCrossAlignment.end,
    _ => WrapCrossAlignment.center,
  };

  Widget _body() => switch ((direction, wrap)) {
    (Axis.vertical, _) => Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      children: children,
    ),
    (Axis.horizontal, true) => SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: _wrapAlignment,
        crossAxisAlignment: _wrapCrossAlignment,
        spacing: spacing,
        runSpacing: runSpacing ?? spacing,
        children: children,
      ),
    ),
    (Axis.horizontal, false) => Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      children: children,
    ),
  };

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
      child: _body(),
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
