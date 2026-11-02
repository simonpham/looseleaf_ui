import 'package:flutter/rendering.dart';

/// Ties a floating table cell to the empty slots it covers in the table
/// grid: a cell spanning columns (upstream `colSpan`) or a sticky header
/// cell is laid out by [TableFloatLayout] over its slots instead of inside
/// the grid.
class TableFloatLink {
  TableFloatLink({required this.span});

  /// How many columns the cell covers.
  final int span;

  /// The slots' render boxes, in column order.
  final List<RenderBox> slots = [];

  /// Each slot's size from its last layout, for the parent's parent to
  /// read.
  final Map<RenderBox, Size> sizes = {};

  /// The cell's render box, set by [TableFloat].
  RenderBox? content;

  /// The cell's narrowest width, spread over its slots; nothing for a
  /// cell spanning several columns, which never widens them.
  double minWidth(double height) => switch ((span, content)) {
    (1, final cell?) => cell.getMinIntrinsicWidth(height),
    _ => 0,
  };

  /// The cell's natural width when it covers one column.
  double maxWidth(double height) => switch ((span, content)) {
    (1, final cell?) => cell.getMaxIntrinsicWidth(height),
    _ => 0,
  };

  /// The row height the cell needs at [width]: wrapped to the column
  /// when it covers one, on one line when it spans several.
  double height(double width) => switch ((span, content)) {
    (_, null) => 0,
    (1, final cell?) => cell.getMinIntrinsicHeight(width),
    (_, final cell?) => cell.getMinIntrinsicHeight(double.infinity),
  };
}
