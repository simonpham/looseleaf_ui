import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row at an index card's foot (a number, a filing mark): 14 px muted
/// text on the 30 px line, [children] spread apart 12 px at least.
///
/// Mirrors `IndexCardFooter` in upstream `src/components/ui/index-card.tsx`.
class IndexCardFooter extends StatelessWidget {
  const IndexCardFooter({super.key, required this.children});

  /// The footer's pieces, usually [Text]s.
  final List<Widget> children;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: Spacing.d12,
        children: children,
      ),
    );
  }
}
