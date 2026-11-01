import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A popover's heading block: its [PopoverTitle] and [PopoverDescription],
/// 4 px apart, in the small size.
///
/// Mirrors `PopoverHeader` in upstream `src/components/ui/popover.tsx`.
class PopoverHeader extends StatelessWidget {
  const PopoverHeader({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d4,
        children: children,
      ),
    );
  }
}
