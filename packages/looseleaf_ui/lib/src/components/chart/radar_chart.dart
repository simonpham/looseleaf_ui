import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// A pencil web with a washed and shaded shape per series. The spokes are
/// the keyboard stops.
///
/// Mirrors `RadarChart` in upstream `src/components/ui/chart.tsx`.
class RadarChart extends ChartWidget {
  const RadarChart({
    super.key,
    required this.data,
    this.xKey,
    this.series,
    this.max,
    this.levels = 4,
    this.fill = true,
    this.dots = true,
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

  /// One row per axis.
  final List<ChartRow> data;

  /// The key naming an axis.
  final String? xKey;

  /// The keys to draw.
  final List<String>? series;

  /// The value at the rim; a tidy number above the largest by default.
  final double? max;

  /// Rings of the web.
  final int levels;

  /// Shades the shapes.
  final bool fill;

  /// A marker on each vertex.
  final bool dots;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  String get _xKey => xKey ?? ChartKeys.xKey(data);

  List<String> _keys(ChartConfig? config) =>
      series ?? ChartKeys.series(data, _xKey, config);

  @override
  ChartConfig autoConfig() => {
    for (final key in _keys(config)) key: ChartSeriesConfig(label: key),
  };

  @override
  bool get legendByDefault => _keys(config).length > 1;

  ({int slot, SeriesLook look}) _look(
    ChartConfig config,
    ChartPatterns patterns,
    List<String> keys,
    String key,
  ) {
    final slot = ChartKeys.slot(config, key, keys.indexOf(key));
    return (
      slot: slot,
      look: seriesLook(
        XYKind.area,
        slot,
        keys.length,
        patterns.look,
        pattern: config[key]?.pattern,
        marker: config[key]?.marker,
        dash: config[key]?.dash,
      ),
    );
  }

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) {
    final keys = _keys(config);
    return [
      for (final key in keys)
        if (_look(config, patterns, keys, key) case (:final slot, :final look))
          ChartLegendEntry(
            key: key,
            slot: slot,
            pattern: look.pattern,
            marker: look.marker,
            kind: XYKind.area,
          ),
    ];
  }

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final keys = _keys(scope.config);
    final format = valueFormatter ?? formatNumber;
    final rim =
        max ??
        radarRim(
          [
            0.0,
            for (final key in keys)
              for (final row in data) toNum(row[key]) ?? 0,
          ].reduce(math.max),
          levels.toDouble(),
        );
    final drawn = [
      for (final key in keys)
        if (!scope.hidden.contains(key)) key,
    ];
    final rs = [
      for (final key in drawn)
        if (_look(scope.config, scope.patterns, keys, key) case (
          :final slot,
          :final look,
        ))
          RadarSeries(
            key: key,
            name: ChartKeys.label(scope.config, key),
            slot: slot,
            pattern: look.pattern,
            marker: look.marker,
            values: [for (final row in data) toNum(row[key])],
          ),
    ];
    final empty = rs.isEmpty || data.length < 3;
    final spec = RadarSpec(
      axes: [for (final row in data) jsString(row[_xKey] ?? '')],
      series: rs,
      max: rim,
      levels: levels.toDouble(),
      ringLabels: [
        for (var l = 0; l < levels; l++)
          formatCompact(rim * (levels - l) / levels),
      ],
      fill: fill,
      patterns: scope.patterns != ChartPatterns.off,
      dots: dots,
      state: switch ((loading, empty)) {
        (true, _) => ChartState.loading,
        (false, true) => ChartState.empty,
        (false, false) => ChartState.ready,
      },
      stateText: switch (loading) {
        true => 'Loading',
        false => emptyText,
      },
    );
    final name = label ?? 'Radar chart';
    String valueAt(RadarSeries s, int i) =>
        switch (s.values.elementAtOrNull(i)) {
          final v? when isNum(v) => format(v),
          _ => '',
        };
    return ChartCanvas<RadarSpec>(
      recipe: chartRadarRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: _summary(spec, name, format),
      table: TableModel(
        head: [_xKey, for (final s in spec.series) s.name],
        rows: [
          for (final (i, axis) in spec.axes.indexed)
            [axis, for (final s in spec.series) valueAt(s, i)],
        ],
      ),
      describe: (index, _, _) {
        final axis = spec.axes.elementAtOrNull(index);
        if (axis == null) return null;
        final items = [
          for (final s in spec.series)
            if (s.values.elementAtOrNull(index) case final v? when isNum(v))
              ChartTooltipItem(
                dataKey: s.key,
                name: s.name,
                value: v,
                payload: data.elementAtOrNull(index),
                slot: s.slot,
                pattern: s.pattern,
                marker: s.marker,
                kind: XYKind.area,
              ),
        ];
        return ChartDescribed(
          label: axis,
          payload: items,
          announce:
              '$axis: ${items.map((i) => '${i.name} ${format((i.value as num).toDouble())}').join(', ')}',
        );
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
    );
  }

  String _summary(RadarSpec spec, String name, ChartValueFormatter format) {
    if (spec.state == ChartState.loading) return '$name. Loading.';
    if (spec.state == ChartState.empty) return '$name. No data.';
    final each = [
      for (final s in spec.series)
        '${s.name}: ${[
          for (final (i, axis) in spec.axes.indexed) '$axis ${switch (s.values.elementAtOrNull(i)) {
              final v? when isNum(v) => format(v),
              _ => 'none',
            }}',
        ].join(', ')}',
    ];
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    return '${title}Radar chart with ${spec.axes.length} axes and ${spec.series.length} series, scaled to ${format(spec.max)}. ${each.join('. ')}.$extra';
  }
}
