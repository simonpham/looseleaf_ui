import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An [InkItem]'s title: bold, 16 px, set snug; [trailing] (a badge) sits
/// 8 px after it.
///
/// Mirrors `ItemTitle` in upstream `src/components/ui/item.tsx`
/// (`text-base leading-snug font-bold`).
class ItemTitle extends StatelessWidget {
  const ItemTitle(this.child, {super.key, this.trailing});

  /// The title, usually a [Text].
  final Widget child;

  /// Something after the title, like a badge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 16,
        cssLineHeight: 1.375,
        fontWeight: FontWeight.w700,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d8,
        children: [
          Flexible(child: child),
          ?trailing,
        ],
      ),
    );
  }
}
