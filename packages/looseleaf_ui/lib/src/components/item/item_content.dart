import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The text of an [InkItem]: an [ItemTitle] over an [ItemDescription], 4 px
/// apart. The first content in a row takes the room left.
///
/// Mirrors `ItemContent` in upstream `src/components/ui/item.tsx`.
class ItemContent extends StatelessWidget {
  const ItemContent({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d4,
    children: children,
  );
}
