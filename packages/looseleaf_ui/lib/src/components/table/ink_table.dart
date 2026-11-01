import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/table/table.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A table ruled by hand: script column titles over a double ink rule,
/// pencil rules between rows (each offset so no two look alike, faded at
/// the row ends), and a highlighter band behind a hovered or selected row.
/// Columns share the width; a table wider than its space scrolls sideways.
///
/// Named `InkTable` because Flutter's widgets library has a `Table`.
///
/// ```dart
/// InkTable(
///   header: TableHeader(rows: [
///     InkTableRow(cells: [TableHead(child: Text('Invoice')), TableHead(child: Text('Amount'))]),
///   ]),
///   body: TableBody(rows: [
///     InkTableRow(cells: [InkTableCell(child: Text('INV001')), InkTableCell(child: Text(r'$250.00'))]),
///   ]),
///   caption: TableCaption(child: Text('A list of your recent invoices.')),
/// )
/// ```
///
/// Mirrors `Table` in upstream `src/components/ui/table.tsx`.
class InkTable extends StatefulWidget {
  const InkTable({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.caption,
    this.columnWidths,
  });

  final TableHeader? header;
  final TableBody body;
  final TableFooter? footer;

  /// The line under the table, usually a [TableCaption].
  final Widget? caption;

  /// Widths per column index; columns share the width by their content
  /// otherwise.
  final Map<int, TableColumnWidth>? columnWidths;

  @override
  State<InkTable> createState() => _InkTableState();
}

class _InkTableState extends State<InkTable> {
  final List<ValueNotifier<double>> _bands = [];
  final List<bool> _hovered = [];

  /// `h-11 compact:h-9 calm:h-8`.
  static const _rowHeight = ByDensity(
    comfortable: Spacing.d44,
    compact: Spacing.d36,
    calm: Spacing.d32,
  );

  static const double _hoverBand = 0.4;

  /// The band of header and footer rows, which never show one.
  static final ValueNotifier<double> _noBand = ValueNotifier(0);

  void _syncBands() {
    final rows = widget.body.rows;
    while (_bands.length < rows.length) {
      _bands.add(ValueNotifier(0));
      _hovered.add(false);
    }
    while (_bands.length > rows.length) {
      _bands.removeLast().dispose();
      _hovered.removeLast();
    }
    for (final (index, row) in rows.indexed) {
      _bands[index].value = _bandOf(row, hovered: _hovered[index]);
    }
  }

  static double _bandOf(InkTableRow row, {required bool hovered}) {
    if (row.selected) return 1;
    if (hovered || row.expanded) return _hoverBand;
    return 0;
  }

  void _hover(int index, bool hovered) {
    if (_hovered[index] == hovered) return;
    _hovered[index] = hovered;
    _bands[index].value = _bandOf(widget.body.rows[index], hovered: hovered);
  }

  @override
  void dispose() {
    for (final band in _bands) {
      band.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncBands();
    final theme = LooseleafTheme.of(context);
    final direction = Directionality.of(context);
    final height = _rowHeight.of(context);
    final rows = <TableRow>[
      for (final (index, row) in (widget.header?.rows ?? const []).indexed)
        _row(
          theme,
          direction,
          height,
          TableSection.header,
          index,
          row,
          rule: true,
        ),
      for (final (index, row) in widget.body.rows.indexed)
        _row(
          theme,
          direction,
          height,
          TableSection.body,
          index,
          row,
          rule: index < widget.body.rows.length - 1,
          band: _bands[index],
        ),
      for (final (index, row) in (widget.footer?.rows ?? const []).indexed)
        _row(
          theme,
          direction,
          height,
          TableSection.footer,
          index,
          row,
          rule: index == 0,
        ),
    ];
    final table = DefaultTextStyle.merge(
      style: theme.typography.face(KevinSansFace.hand, cssSize: 15),
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
        columnWidths: widget.columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        children: rows,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final caption = widget.caption;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: switch (constraints.hasBoundedWidth) {
                true => constraints.maxWidth,
                false => 0,
              },
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [table, ?caption],
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _row(
    LooseleafThemeData theme,
    TextDirection direction,
    double height,
    TableSection section,
    int index,
    InkTableRow row, {
    required bool rule,
    ValueNotifier<double>? band,
  }) {
    final cells = row.cells;
    final rowBand = band ?? _noBand;
    final footer = section == TableSection.footer;
    return TableRow(
      children: [
        for (final (column, cell) in cells.indexed)
          MouseRegion(
            onEnter: switch (section) {
              TableSection.body => (_) => _hover(index, true),
              _ => null,
            },
            onExit: switch (section) {
              TableSection.body => (_) => _hover(index, false),
              _ => null,
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: row.onTap,
              child: CustomPaint(
                painter: TableCellPainter(
                  theme: theme,
                  section: section,
                  row: index,
                  column: column,
                  first: column == 0,
                  last: column == cells.length - 1,
                  rule: rule,
                  direction: direction,
                  band: rowBand,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontWeight: switch (footer) {
                          true => FontWeight.w700,
                          false => null,
                        },
                      ),
                      child: cell,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
