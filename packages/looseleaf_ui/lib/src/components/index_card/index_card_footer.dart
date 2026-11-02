import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row at an index card's foot (a number, a filing mark): 14 px muted
/// text on the 30 px line, [children] spread apart [spacing] (12 px) at
/// least. [wrap] lets the pieces run onto more lines from the start, as
/// upstream's `flex-wrap justify-start`, instead of spreading one row.
///
/// Mirrors `IndexCardFooter` in upstream `src/components/ui/index-card.tsx`.
class IndexCardFooter extends StatelessWidget {
  const IndexCardFooter({
    super.key,
    required this.children,
    this.wrap = false,
    this.spacing = Spacing.d12,
  });

  /// The footer's pieces, usually [Text]s.
  final List<Widget> children;

  /// Wraps the pieces onto more lines, packed at the start.
  final bool wrap;

  /// The least gap between pieces on a line.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 30 / 14,
        color: theme.colors.inkMuted,
      ),
      child: switch (wrap) {
        true => Wrap(
          spacing: spacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
        false => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: spacing,
          children: children,
        ),
      },
    );
  }
}
