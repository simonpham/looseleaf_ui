import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The buttons at the end of an [InkItem], 8 px apart.
///
/// Mirrors `ItemActions` in upstream `src/components/ui/item.tsx`.
class ItemActions extends StatelessWidget {
  const ItemActions({super.key, required this.children});

  /// The actions.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d8,
    children: children,
  );
}
