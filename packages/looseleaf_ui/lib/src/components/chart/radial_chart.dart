import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Concentric arcs in pale tracks: one ring per row, filled to its value
/// out of [max] (a row's own `max` wins). Ring names sit in the open
/// quadrant.
///
/// Mirrors `RadialChart` in upstream `src/components/ui/chart.tsx`.
class RadialChart extends ChartWidget {
  const RadialChart({
    super.key,
    required this.data,
    this.nameKey,
    this.valueKey,
    this.max = 100,
    this.startAngle = 0,
    this.endAngle = 270,
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

  /// One row per ring.
  final List<ChartRow> data;

  /// The key naming a ring.
  final String? nameKey;

  /// The key sizing a ring.
  final String? valueKey;

  /// The value that fills a ring.
  final double max;

  /// Degrees clockwise from twelve o'clock.
  final double startAngle;

  /// Degrees clockwise from twelve o'clock.
  final double endAngle;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  /// Text in the hole; its info has no active slice.
  final ChartCenterBuilder? centerLabel;

  String get _nameKey => nameKey ?? ChartKeys.xKey(data);

  String get _valueKey =>
      valueKey ?? ChartKeys.series(data, _nameKey, null).firstOrNull ?? 'value';

  List<({String key, int slot, double value, double max})> _all(
    ChartConfig config,
  ) => [
    for (final (index, row) in data.indexed)
      (
        key: jsString(row[_nameKey] ?? index),
        slot: ChartKeys.slot(config, jsString(row[_nameKey] ?? index), index),
        value: toNum(row[_valueKey]) ?? 0,
        max: toNum(row['max']) ?? max,
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
  bool get legendByDefault => data.length > 1;

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
    final format = valueFormatter ?? formatNumber;
    final drawn = [
      for (final a in all)
        if (!scope.hidden.contains(a.key)) a,
    ];
    final spec = RadialSpec(
      rings: [
        for (final a in drawn)
          RadialRing(
            key: a.key,
            name: ChartKeys.label(scope.config, a.key),
            slot: a.slot,
            pattern: ChartKeys.slicePattern(
              scope.config,
              scope.patterns,
              a.key,
              a.slot,
              all.length,
            ),
            value: a.value,
            max: a.max,
          ),
      ],
      start: startAngle,
      end: endAngle,
      patterns: scope.patterns != ChartPatterns.off,
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
    final name = label ?? 'Radial bar chart';
    final center = centerLabel;
    final total = drawn.fold<double>(0, (sum, a) => sum + a.value);
    return ChartCanvas<RadialSpec>(
      recipe: chartRadialRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: _summary(spec, name, format),
      table: TableModel(
        head: [_nameKey, _valueKey, 'Of'],
        rows: [
          for (final r in spec.rings) [r.name, format(r.value), format(r.max)],
        ],
      ),
      describe: (index, _, _) {
        final ring = spec.rings.elementAtOrNull(index);
        if (ring == null) return null;
        return ChartDescribed(
          label: ring.name,
          payload: [
            ChartTooltipItem(
              dataKey: ring.key,
              name: ring.name,
              value: ring.value,
              slot: ring.slot,
              pattern: ring.pattern,
              kind: XYKind.bar,
              unit: ' of ${format(ring.max)}',
            ),
          ],
          announce:
              '${ring.name}: ${format(ring.value)} of ${format(ring.max)}',
        );
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
      overlay: switch ((center, spec.state)) {
        (final build?, ChartState.ready) => (context, layout, _) {
          if (layout is! RadialLayout) return const SizedBox.shrink();
          return ChartAtPoint(
            x: layout.cx,
            y: layout.cy,
            child: build((total: total, active: null)),
          );
        },
        _ => null,
      },
    );
  }

  String _summary(RadialSpec spec, String name, ChartValueFormatter format) {
    if (spec.state == ChartState.loading) return '$name. Loading.';
    if (spec.state == ChartState.empty) return '$name. No data.';
    final count = spec.rings.length;
    final plural = switch (count) {
      1 => '',
      _ => 's',
    };
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    final rings = [
      for (final r in spec.rings)
        '${r.name} ${format(r.value)} of ${format(r.max)}',
    ];
    return '${title}Radial bar chart with $count ring$plural: ${rings.join(', ')}.$extra';
  }
}
