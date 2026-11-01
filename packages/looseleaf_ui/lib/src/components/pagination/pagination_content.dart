import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The row of a [Pagination]: links, steps and ellipses 6 apart.
///
/// Mirrors `PaginationContent` (with `PaginationItem`, which needs no
/// widget of its own here) in upstream `src/components/ui/pagination.tsx`.
class PaginationContent extends StatelessWidget {
  const PaginationContent({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d6,
    children: children,
  );
}
