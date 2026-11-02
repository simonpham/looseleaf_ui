import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/table/float/float.dart';
import 'package:looseleaf_ui/src/components/table/table.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A table ruled by hand: script column titles over a double ink rule,
/// pencil rules between rows (each offset so no two look alike, faded at
/// the row ends), and a highlighter band behind a hovered or selected row.
/// Columns share the width; a table wider than its space scrolls sideways.
/// An [InkTableCell] can span columns ([InkTableCell.colSpan]); a [sticky]
/// table scrolls its body under a header that stays put.
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
    this.sticky = false,
    this.maxHeight,
    this.controller,
  });

  final TableHeader? header;
  final TableBody body;
  final TableFooter? footer;

  /// The line under the table, usually a [TableCaption].
  final Widget? caption;

  /// Widths per column index; columns share the width by their content
  /// otherwise.
  final Map<int, TableColumnWidth>? columnWidths;

  /// Pins the header rows on the paper color while the body scrolls under
  /// them (upstream `sticky`). Give the table a [maxHeight] to scroll in.
  final bool sticky;

  /// The height the table scrolls in, like upstream's
  /// `containerClassName="max-h-72"`; null lets it grow.
  final double? maxHeight;

  /// Drives the vertical scroll of a table given a [maxHeight].
  final ScrollController? controller;

  @override
  State<InkTable> createState() => _InkTableState();
}

class _InkTableState extends State<InkTable> {
  ScrollController? _ownScroll;
  final ValueNotifier<double> _stick = ValueNotifier(0);
  ScrollController? _listened;
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

  ScrollController get _scroll =>
      widget.controller ?? (_ownScroll ??= ScrollController());

  void _onScroll() {
    final scroll = _listened;
    if (scroll == null || !scroll.hasClients) return;
    _stick.value = scroll.offset;
  }

  void _listen() {
    final next = switch (widget.maxHeight) {
      null => null,
      _ => _scroll,
    };
    if (identical(next, _listened)) return;
    _listened?.removeListener(_onScroll);
    _listened = next;
    next?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _listened?.removeListener(_onScroll);
    _ownScroll?.dispose();
    _stick.dispose();
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
    final floats = <Widget>[];
    final columns = _columnCount;
    TableRow row(
      TableSection section,
      int index,
      InkTableRow row, {
      required bool rule,
      ValueNotifier<double>? band,
    }) => _row(
      _RowContext(
        theme: theme,
        direction: direction,
        height: height,
        section: section,
        index: index,
        rule: rule,
        band: band ?? _noBand,
        columns: columns,
        stick: widget.sticky && section == TableSection.header,
        floats: floats,
      ),
      row,
    );
    final rows = <TableRow>[
      for (final (index, header) in (widget.header?.rows ?? const []).indexed)
        row(TableSection.header, index, header, rule: true),
      for (final (index, body) in widget.body.rows.indexed)
        row(
          TableSection.body,
          index,
          body,
          rule: index < widget.body.rows.length - 1,
          band: _bands[index],
        ),
      for (final (index, footer) in (widget.footer?.rows ?? const []).indexed)
        row(TableSection.footer, index, footer, rule: index == 0),
    ];
    final grid = Table(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
      columnWidths: widget.columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      children: rows,
    );
    final table = DefaultTextStyle.merge(
      style: theme.typography.face(KevinSansFace.hand, cssSize: 15),
      child: switch (floats.isEmpty) {
        true => grid,
        false => TableFloatLayout(
          stick: switch (widget.sticky) {
            true => _stick,
            false => null,
          },
          children: [grid, ...floats],
        ),
      },
    );
    final caption = widget.caption;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [table, ?caption],
    );
    final sideways = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: switch (constraints.hasBoundedWidth) {
          true => _FitWidth(width: constraints.maxWidth, child: content),
          false => IntrinsicWidth(child: content),
        },
      ),
    );
    _listen();
    final maxHeight = widget.maxHeight;
    if (maxHeight == null) return sideways;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(controller: _scroll, child: sideways),
    );
  }

  int get _columnCount {
    var count = 0;
    for (final row in [
      ...?widget.header?.rows,
      ...widget.body.rows,
      ...?widget.footer?.rows,
    ]) {
      var slots = 0;
      for (final cell in row.cells) {
        slots += _span(cell);
      }
      count = math.max(count, slots);
    }
    return count;
  }

  static int _span(Widget cell) => switch (cell) {
    InkTableCell(:final colSpan) => math.max(1, colSpan),
    _ => 1,
  };

  TableRow _row(_RowContext at, InkTableRow row) {
    final slots = <Widget>[];
    var column = 0;
    for (final cell in row.cells) {
      final span = _span(cell);
      final decorated = _cell(at, row, cell, column, span);
      if (span == 1 && !at.stick) {
        slots.add(decorated);
        column++;
        continue;
      }
      final link = TableFloatLink(span: span);
      at.floats.add(
        TableFloat(
          link: link,
          stick: at.stick,
          child: switch (at.stick) {
            true => ColoredBox(color: at.theme.colors.card, child: decorated),
            false => decorated,
          },
        ),
      );
      for (var covered = 0; covered < span; covered++) {
        slots.add(TableFloatSlot(link: link));
      }
      column += span;
    }
    while (slots.length < at.columns) {
      slots.add(const SizedBox.shrink());
    }
    return TableRow(children: slots);
  }

  Widget _cell(
    _RowContext at,
    InkTableRow row,
    Widget cell,
    int column,
    int span,
  ) => MouseRegion(
    onEnter: switch (at.section) {
      TableSection.body => (_) => _hover(at.index, true),
      _ => null,
    },
    onExit: switch (at.section) {
      TableSection.body => (_) => _hover(at.index, false),
      _ => null,
    },
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: row.onTap,
      child: CustomPaint(
        painter: TableCellPainter(
          theme: at.theme,
          section: at.section,
          row: at.index,
          column: column,
          first: column == 0,
          last: column + span >= at.columns,
          rule: at.rule,
          direction: at.direction,
          band: at.band,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: at.height),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontWeight: switch (at.section == TableSection.footer) {
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
  );
}

/// What every cell of one row shares.
class _RowContext {
  const _RowContext({
    required this.theme,
    required this.direction,
    required this.height,
    required this.section,
    required this.index,
    required this.rule,
    required this.band,
    required this.columns,
    required this.stick,
    required this.floats,
  });

  final LooseleafThemeData theme;
  final TextDirection direction;
  final double height;
  final TableSection section;
  final int index;
  final bool rule;
  final ValueNotifier<double> band;
  final int columns;
  final bool stick;
  final List<Widget> floats;
}

/// Lays the table out at [width], or at its narrowest when that is wider:
/// wrapping cells shrink first, like a browser table, and only a table
/// that cannot fit scrolls sideways.
class _FitWidth extends SingleChildRenderObjectWidget {
  const _FitWidth({required this.width, required super.child});

  final double width;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFitWidth(width);

  @override
  void updateRenderObject(BuildContext context, _RenderFitWidth renderObject) {
    renderObject.width = width;
  }
}

class _RenderFitWidth extends RenderProxyBox {
  _RenderFitWidth(this._width);

  double _width;

  double get width => _width;

  set width(double value) {
    if (value == _width) return;
    _width = value;
    markNeedsLayout();
  }

  double _widthFor(double height) {
    final child = this.child;
    if (child == null) return _width;
    return math.max(_width, child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicWidth(double height) => _widthFor(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _widthFor(height);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    final width = _widthFor(double.infinity);
    if (child == null) return constraints.constrain(Size(width, 0));
    return constraints.constrain(
      child.getDryLayout(
        BoxConstraints.tightFor(width: width).enforce(constraints),
      ),
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    final width = _widthFor(double.infinity);
    if (child == null) {
      size = constraints.constrain(Size(width, 0));
      return;
    }
    child.layout(
      BoxConstraints.tightFor(width: width).enforce(constraints),
      parentUsesSize: true,
    );
    size = constraints.constrain(child.size);
  }
}
