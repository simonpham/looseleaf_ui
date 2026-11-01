import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/item/item_scope.dart';

/// A list of [InkItem]s, stacked; [ruled] draws a blue pencil rule under every
/// row, so the rules always match the rows. Put [ItemSeparator]s between
/// rows for pencil lines.
///
/// Mirrors `ItemGroup` in upstream `src/components/ui/item.tsx`.
class ItemGroup extends StatelessWidget {
  const ItemGroup({
    super.key,
    required this.children,
    this.ruled = false,
    this.semanticLabel,
  });

  /// The rows and separators.
  final List<Widget> children;

  /// A blue rule under every row.
  final bool ruled;

  /// The list's accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    role: SemanticsRole.list,
    label: semanticLabel,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in children.indexed)
          ItemScope(ruled: ruled, index: index, child: child),
      ],
    ),
  );
}
