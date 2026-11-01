import 'package:flutter/widgets.dart';

/// One row of an [InkTable]: its [cells] ([TableHead]s or
/// [InkTableCell]s), 44 tall (36 compact, 32 calm) at least.
///
/// Named `InkTableRow` because Flutter's widgets library has a `TableRow`.
/// Mirrors `TableRow` in upstream `src/components/ui/table.tsx`.
class InkTableRow {
  const InkTableRow({
    required this.cells,
    this.selected = false,
    this.expanded = false,
    this.onTap,
  });

  final List<Widget> cells;

  /// Fills the highlighter band (upstream `data-state="selected"`).
  final bool selected;

  /// Half-fills the band, as for a row whose details are open (upstream
  /// `:has([aria-expanded=true])`).
  final bool expanded;

  /// Called when the row is tapped.
  final VoidCallback? onTap;
}
