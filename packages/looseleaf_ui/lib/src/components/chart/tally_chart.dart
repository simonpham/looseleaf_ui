import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Counts as hand-tallied marks: four uprights and a slash for every five,
/// in the row's color. When a row is too long for the width each mark
/// stands for more ([unit]), and the chart says so.
///
/// Mirrors `TallyChart` in upstream `src/components/ui/chart.tsx`.
class TallyChart extends ChartWidget {
  const TallyChart({
    super.key,
    required this.data,
    this.nameKey,
    this.valueKey,
    this.unit = 0,
    this.valueFormatter,
    super.config,
    super.tooltip,
    super.legend,
    super.label,
    super.description,
    super.loading,
    super.emptyText,
    super.animate,
    super.seed,
    super.onActiveChange,
    super.onSelect,
  });

  /// One row per line of the board.
  final List<ChartRow> data;

  /// The key naming a row.
  final String? nameKey;

  /// The key counting a row.
  final String? valueKey;

  /// What one mark stands for; automatic at 0.
  final double unit;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  String get _nameKey => nameKey ?? ChartKeys.xKey(data);

  String get _valueKey =>
      valueKey ?? ChartKeys.series(data, _nameKey, null).firstOrNull ?? 'value';

  List<({String key, int slot, double count})> _all(ChartConfig config) => [
    for (final (index, row) in data.indexed)
      (
        key: jsString(row[_nameKey] ?? index),
        slot: ChartKeys.slot(config, jsString(row[_nameKey] ?? index), index),
        count: math.max(0, JsMath.round(toNum(row[_valueKey]) ?? 0)),
      ),
  ];

  @override
  ChartConfig autoConfig() => {
    for (final row in data)
      jsString(row[_nameKey]): ChartSeriesConfig(
        label: jsString(row[_nameKey]),
      ),
  };

  @override
  bool get legendByDefault => false;

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) => [
    for (final a in _all(config))
      ChartLegendEntry(key: a.key, slot: a.slot, kind: XYKind.bar),
  ];

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final format = valueFormatter ?? formatNumber;
    final drawn = [
      for (final a in _all(scope.config))
        if (!scope.hidden.contains(a.key)) a,
    ];
    final spec = TallySpec(
      rows: [
        for (final a in drawn)
          TallyRow(
            key: a.key,
            name: ChartKeys.label(scope.config, a.key),
            slot: a.slot,
            count: a.count,
          ),
      ],
      unit: unit,
      totals: [for (final a in drawn) format(a.count)],
      state: switch ((loading, drawn.isNotEmpty)) {
        (true, _) => ChartState.loading,
        (false, true) => ChartState.ready,
        (false, false) => ChartState.empty,
      },
      stateText: switch (loading) {
        true => 'Loading',
        false => emptyText,
      },
    );
    final name = label ?? 'Tally chart';
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    final summary = switch (spec.state) {
      ChartState.ready =>
        '${title}Tally chart: ${[for (final r in spec.rows) '${r.name} ${format(r.count)}'].join(', ')}.$extra',
      ChartState.loading => '$name. Loading.',
      ChartState.empty => '$name. No data.',
    };
    return ChartCanvas<TallySpec>(
      recipe: chartTallyRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: summary,
      table: TableModel(
        head: [_nameKey, _valueKey],
        rows: [
          for (final r in spec.rows) [r.name, format(r.count)],
        ],
      ),
      describe: (index, _, _) {
        final row = spec.rows.elementAtOrNull(index);
        if (row == null) return null;
        return ChartDescribed(
          label: row.name,
          payload: [
            ChartTooltipItem(
              dataKey: row.key,
              name: row.name,
              value: row.count,
              slot: row.slot,
              kind: XYKind.bar,
            ),
          ],
          announce: '${row.name}: ${format(row.count)}',
        );
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
    );
  }
}
