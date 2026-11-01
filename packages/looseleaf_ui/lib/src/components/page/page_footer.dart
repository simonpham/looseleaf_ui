import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page's foot: small muted [children] spread across the row, 16 px
/// apart at least, 8 px below the content.
///
/// Mirrors `PageFooter` in upstream `src/components/ui/page.tsx`.
class PageFooter extends StatelessWidget {
  const PageFooter({super.key, required this.children});

  /// The footer's pieces, usually a status and a page number.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: theme.colors.inkMuted,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: Spacing.d16,
          children: children,
        ),
      ),
    );
  }
}
