import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Squares colored in shades of one marker: a calendar (weeks across,
/// weekdays down, month names on top) or a grid of your own rows and
/// columns. Arrow keys move over the cells: left and right by week (or
/// column), up and down by day (or row), Page Up and Down by a week.
///
/// Mirrors `Heatmap` in upstream `src/components/ui/chart.tsx`.
class Heatmap extends ChartWidget {
  const Heatmap({
    super.key,
    required this.data,
    this.variant = HeatVariant.calendar,
    this.dateKey = 'date',
    this.valueKey = 'value',
    this.weeks,
    this.end,
    this.weekStart = 0,
    this.rowKey = 'row',
    this.colKey = 'col',
    this.rows,
    this.cols,
    this.levels = 5,
    this.thresholds,
    this.slot,
    this.series,
    this.unit,
    this.valueFormatter,
    this.showLegend = true,
    super.config,
    super.tooltip,
    super.label,
    super.description,
    super.loading,
    super.emptyText,
    super.animate,
    super.seed,
    super.onActiveChange,
    super.onSelect,
  });

  /// Calendar: rows with a date and a value. Grid: rows with a row name, a
  /// column name and a value.
  final List<ChartRow> data;

  /// Calendar or grid.
  final HeatVariant variant;

  /// The calendar's date key (`YYYY-MM-DD` or a [DateTime], read in UTC).
  final String dateKey;

  /// The value key.
  final String valueKey;

  /// Weeks shown.
  final int? weeks;

  /// The last day shown.
  final Object? end;

  /// 0 starts weeks on Sunday, 1 on Monday.
  final int weekStart;

  /// The grid's row key.
  final String rowKey;

  /// The grid's column key.
  final String colKey;

  /// The grid's rows, in order.
  final List<String>? rows;

  /// The grid's columns, in order.
  final List<String>? cols;

  /// Shades.
  final int levels;

  /// The value at which each shade starts.
  final List<double>? thresholds;

  /// The palette slot; the green pencil by default.
  final int? slot;

  /// The config key whose color to use.
  final String? series;

  /// What a value counts, shown in the tooltip.
  final String? unit;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  /// The Less / More key.
  final bool showLegend;

  bool get _grid => variant == HeatVariant.grid;

  @override
  ChartConfig autoConfig() => const {};

  @override
  bool get legendByDefault => false;

  @override
  double get standaloneAspectRatio => switch (_grid) {
    true => 16 / 10,
    false => 53 / 14,
  };

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) => const [];

  HeatCells _cells() => switch (_grid) {
    true => buildGrid(
      [
        for (final r in data)
          (row: r[rowKey], col: r[colKey], value: r[valueKey]),
      ],
      levels: levels,
      rows: rows,
      cols: cols,
      thresholds: thresholds,
    ),
    false => buildCalendar(
      [for (final r in data) (date: r[dateKey], value: r[valueKey])],
      levels: levels,
      weeks: weeks,
      end: end,
      weekStart: weekStart,
      thresholds: thresholds,
    ),
  };

  String _cellName(HeatCells cells, int k) {
    if (!_grid) return formatDay(cells.days[k], true);
    final row = cells.rowLabels.elementAtOrNull(k ~/ cells.cols)?.text ?? '';
    final col = cells.colLabels.elementAtOrNull(k % cells.cols)?.text ?? '';
    return '$row, $col';
  }

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final format = valueFormatter ?? formatNumber;
    final own = switch (series) {
      final key? => scope.keys.indexOf(key),
      null => -1,
    };
    final sl =
        slot ??
        switch (own >= 0) {
          true => own,
          false => 2,
        };
    final cells = _cells();
    final spec = HeatSpec(
      cols: cells.cols,
      rows: cells.rows,
      levels: cells.levels,
      levelCount: levels,
      colLabels: cells.colLabels,
      rowLabels: cells.rowLabels,
      slot: sl,
      variant: variant,
      legend: switch (showLegend) {
        true => (less: 'Less', more: 'More'),
        false => null,
      },
      patterns: scope.patterns != ChartPatterns.off,
      state: switch ((loading, cells.levels.any((l) => l >= 0))) {
        (true, _) => ChartState.loading,
        (false, true) => ChartState.ready,
        (false, false) => ChartState.empty,
      },
      stateText: switch (loading) {
        true => 'Loading',
        false => emptyText,
      },
    );
    final noun = switch (_grid) {
      true => 'Heat map',
      false => 'Calendar heat map',
    };
    final name = label ?? noun;
    final unitText = switch (unit) {
      final u? => ' $u',
      null => '',
    };
    final table = <List<String>>[
      for (final (k, level) in cells.levels.indexed)
        if (cells.values[k] case final v?
            when level >= 0 && isNum(v) && (_grid || v > 0))
          [_cellName(cells, k), format(v)],
    ];
    const cap = 240;
    return ChartCanvas<HeatSpec>(
      recipe: chartHeatRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: _summary(spec, cells, name, noun, unitText, format),
      table: TableModel(
        head: [
          switch (_grid) {
            true => 'Cell',
            false => 'Day',
          },
          unit ?? 'Value',
        ],
        rows: table.take(cap).toList(),
        clipped: switch (table.length > cap) {
          true => (shown: cap, total: table.length),
          false => null,
        },
      ),
      describe: (index, _, _) {
        final v = cells.values.elementAtOrNull(index);
        final level = cells.levels.elementAtOrNull(index) ?? -1;
        if (level < 0 || v == null || !isNum(v)) return null;
        final cell = _cellName(cells, index);
        return ChartDescribed(
          label: cell,
          payload: [
            ChartTooltipItem(
              dataKey: valueKey,
              name: unit ?? 'Value',
              value: v,
              slot: sl,
              kind: XYKind.bar,
            ),
          ],
          announce: '$cell: ${format(v)}$unitText',
        );
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
    );
  }

  String _summary(
    HeatSpec spec,
    HeatCells cells,
    String name,
    String noun,
    String unitText,
    ChartValueFormatter format,
  ) {
    if (spec.state == ChartState.loading) return '$name. Loading.';
    if (spec.state == ChartState.empty) return '$name. No data.';
    final count = cells.levels.where((l) => l >= 0).length;
    final total = cells.values.fold<double>(
      0,
      (sum, v) =>
          sum +
          switch (v) {
            final n? when isNum(n) => n,
            _ => 0,
          },
    );
    final what = switch (_grid) {
      true => 'cells',
      false => 'days',
    };
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    return '$title$noun of $count $what, total ${format(total)}$unitText, busiest ${format(cells.max)}.$extra';
  }
}
