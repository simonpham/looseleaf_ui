import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An [InkItem]'s supporting text: small, muted, at most two lines.
///
/// Mirrors `ItemDescription` in upstream `src/components/ui/item.tsx`
/// (`line-clamp-2 text-sm leading-normal text-muted-foreground`).
class ItemDescription extends StatelessWidget {
  const ItemDescription(this.child, {super.key});

  /// The description, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 1.5,
        color: theme.colors.inkMuted,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}
