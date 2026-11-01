import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A full-width line at the bottom of an [InkItem], its [children] spread to
/// both ends.
///
/// Mirrors `ItemFooter` in upstream `src/components/ui/item.tsx`
/// (`flex basis-full items-center justify-between gap-2`).
class ItemFooter extends StatelessWidget {
  const ItemFooter({super.key, required this.children});

  /// What the line holds.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    spacing: Spacing.d8,
    children: children,
  );
}
