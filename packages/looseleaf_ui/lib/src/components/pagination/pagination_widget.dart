import 'package:flutter/widgets.dart';

/// Page numbers to move through a long list: put a [PaginationContent] in
/// it. Centered in the width it gets.
///
/// ```dart
/// Pagination(
///   child: PaginationContent(children: [
///     PaginationPrevious(onPressed: back),
///     PaginationLink(onPressed: () => go(1), child: Text('1')),
///     PaginationLink(isActive: true, onPressed: () => go(2), child: Text('2')),
///     PaginationEllipsis(),
///     PaginationNext(onPressed: next),
///   ]),
/// )
/// ```
///
/// Mirrors `Pagination` in upstream `src/components/ui/pagination.tsx`.
class Pagination extends StatelessWidget {
  const Pagination({super.key, required this.child, this.label = 'pagination'});

  final Widget child;

  /// The landmark's accessible name.
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    child: Center(child: child),
  );
}
