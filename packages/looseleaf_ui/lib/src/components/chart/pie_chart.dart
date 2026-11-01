import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Slices colored in with a marker, outlined in felt, each with its own
/// pencil pattern and a percentage round the outside. Arrow keys walk the
/// slices; the legend switches them off.
///
/// ```dart
/// PieChart(
///   data: const [{'browser': 'chrome', 'visitors': 275}, …],
///   nameKey: 'browser',
///   valueKey: 'visitors',
/// )
/// ```
///
/// Mirrors `PieChart` in upstream `src/components/ui/chart.tsx`.
class PieChart extends ChartWidget {
  const PieChart({
    super.key,
    required this.data,
    this.nameKey,
    this.valueKey,
    this.innerRadius = 0,
    this.startAngle = 0,
    this.showLabels = true,
    this.valueFormatter,
    this.centerLabel,
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

  /// One row per slice.
  final List<ChartRow> data;

  /// The key naming a slice (and its config entry); the first text key by
  /// default.
  final String? nameKey;

  /// The key holding the amount; the first numeric key by default.
  final String? valueKey;

  /// The fraction of the radius that is hole, 0 to 0.9.
  final double innerRadius;

  /// Degrees clockwise from twelve o'clock.
  final double startAngle;

  /// Percentages round the outside.
  final bool showLabels;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  /// Text in the hole.
  final ChartCenterBuilder? centerLabel;

  String get _nameKey => nameKey ?? ChartKeys.xKey(data);

  String get _valueKey =>
      valueKey ?? ChartKeys.series(data, _nameKey, null).firstOrNull ?? 'value';

  List<({String key, int slot, double value, ChartRow row})> _all(
    ChartConfig config,
  ) => [
    for (final (index, row) in data.indexed)
      (
        key: jsString(row[_nameKey] ?? index),
        slot: ChartKeys.slot(config, jsString(row[_nameKey] ?? index), index),
        value: toNum(row[_valueKey]) ?? 0,
        row: row,
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
  bool get legendByDefault => true;

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) {
    final all = _all(config);
    return [
      for (final a in all)
        ChartLegendEntry(
          key: a.key,
          slot: a.slot,
          pattern: ChartKeys.slicePattern(
            config,
            patterns,
            a.key,
            a.slot,
            all.length,
          ),
        ),
    ];
  }

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final all = _all(scope.config);
    final drawn = [
      for (final a in all)
        if (!scope.hidden.contains(a.key)) a,
    ];
    final format = valueFormatter ?? formatNumber;
    final total = drawn.fold<double>(0, (sum, a) => sum + a.value);
    final spec = PieSpec(
      slices: [
        for (final a in drawn)
          Slice(
            key: a.key,
            name: ChartKeys.label(scope.config, a.key),
            slot: a.slot,
            value: a.value,
            pattern: ChartKeys.slicePattern(
              scope.config,
              scope.patterns,
              a.key,
              a.slot,
              all.length,
              fromConfig: true,
            ),
          ),
      ],
      inner: math.max(0, math.min(0.9, innerRadius)),
      start: startAngle,
      labels: showLabels,
      patterns: scope.patterns != ChartPatterns.off,
      state: switch ((loading, total > 0)) {
        (true, _) => ChartState.loading,
        (false, true) => ChartState.ready,
        (false, false) => ChartState.empty,
      },
      stateText: switch (loading) {
        true => 'Loading',
        false => emptyText,
      },
    );
    final pct = shares([for (final s in spec.slices) s.value]);
    final noun = switch (innerRadius > 0) {
      true => 'Donut chart',
      false => 'Pie chart',
    };
    final name = label ?? noun;
    final center = centerLabel;
    return ChartCanvas<PieSpec>(
      recipe: chartPieRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: _summary(spec, name, noun, total, pct, format),
      table: TableModel(
        head: [_nameKey, _valueKey, 'Share'],
        rows: [
          for (final (i, s) in spec.slices.indexed)
            [s.name, format(s.value), pct[i]],
        ],
      ),
      describe: (index, _, layout) {
        if (layout is! PieLayout) return null;
        final at = layout.sliceOf.elementAtOrNull(index);
        final slice = switch (at) {
          final i? => spec.slices.elementAtOrNull(i),
          null => null,
        };
        if (at == null || slice == null) return null;
        final share = pct[at];
        return ChartDescribed(
          label: slice.name,
          payload: [
            ChartTooltipItem(
              dataKey: slice.key,
              name: slice.name,
              value: slice.value,
              payload: [
                for (final a in all)
                  if (a.key == slice.key) a.row,
              ].firstOrNull,
              slot: slice.slot,
              pattern: slice.pattern,
              kind: XYKind.bar,
              unit: ' ($share)',
            ),
          ],
          announce: '${slice.name}: ${format(slice.value)}, $share',
        );
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
      overlay: switch ((center, spec.state)) {
        (final build?, ChartState.ready) => (context, layout, active) {
          if (layout is! PieLayout) return const SizedBox.shrink();
          final at = switch (active) {
            final point? => layout.sliceOf.elementAtOrNull(point.index),
            null => null,
          };
          final slice = switch (at) {
            final i? => spec.slices.elementAtOrNull(i),
            null => null,
          };
          return ChartAtPoint(
            x: layout.cx,
            y: layout.cy,
            child: build((
              total: total,
              active: switch (slice) {
                final s? => (
                  name: s.name,
                  value: s.value,
                  percent: switch (total) {
                    0 => 0,
                    _ => s.value / total,
                  },
                ),
                null => null,
              },
            )),
          );
        },
        _ => null,
      },
    );
  }

  String _summary(
    PieSpec spec,
    String name,
    String noun,
    double total,
    List<String> pct,
    ChartValueFormatter format,
  ) {
    if (spec.state == ChartState.loading) return '$name. Loading.';
    if (spec.state == ChartState.empty) return '$name. No data.';
    final parts = [
      for (final (i, s) in spec.slices.indexed)
        '${s.name} ${format(s.value)} (${pct[i]})',
    ];
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final count = spec.slices.length;
    final plural = switch (count) {
      1 => '',
      _ => 's',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    return '$title$noun of $count slice$plural, total ${format(total)}: ${parts.join(', ')}.$extra';
  }
}
