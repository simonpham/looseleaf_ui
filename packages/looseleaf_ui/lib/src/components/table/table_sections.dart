import 'package:looseleaf_ui/src/components/table/ink_table_row.dart';

/// The header rows of an [InkTable]: script column titles over a double
/// ink rule.
///
/// Mirrors `TableHeader` in upstream `src/components/ui/table.tsx`.
class TableHeader {
  const TableHeader({required this.rows});

  final List<InkTableRow> rows;
}

/// The body rows of an [InkTable]: pencil rules between them, a
/// highlighter band behind a hovered or selected row.
///
/// Mirrors `TableBody` in upstream `src/components/ui/table.tsx`.
class TableBody {
  const TableBody({required this.rows});

  final List<InkTableRow> rows;
}

/// The footer rows of an [InkTable]: bold, under a double ink rule.
///
/// Mirrors `TableFooter` in upstream `src/components/ui/table.tsx`.
class TableFooter {
  const TableFooter({required this.rows});

  final List<InkTableRow> rows;
}
