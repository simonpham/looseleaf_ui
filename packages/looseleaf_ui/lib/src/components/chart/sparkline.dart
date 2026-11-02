import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One felt pull with a red dot at the end, a shaded area, or a row of
/// marker bars, [width] × [height] (112 × 40 px) on its own; pass
/// `double.infinity` to fill the parent (upstream `w-full`). A picture with
/// a spoken summary; [interactive] gives it a cursor and a tooltip.
///
/// [data] holds numbers (or nulls), or rows read through [dataKey].
///
/// Mirrors `Sparkline` in upstream `src/components/ui/chart.tsx`.
class Sparkline extends ChartWidget {
  const Sparkline({
    super.key,
    required this.data,
    this.dataKey,
    this.xKey,
    this.variant = SparkVariant.line,
    this.slot,
    this.series,
    this.ends = true,
    this.extremes = false,
    this.valueFormatter,
    this.interactive = false,
    this.width = Spacing.d112,
    this.height = Spacing.d40,
    super.config,
    super.tooltip,
    super.label,
    super.animate = false,
    super.seed,
    super.onSelect,
  });

  /// Numbers, or rows.
  final List<Object?> data;

  /// The value key of rows.
  final String? dataKey;

  /// The category key of rows.
  final String? xKey;

  /// Line, area or bars.
  final SparkVariant variant;

  /// The palette slot.
  final int? slot;

  /// The config key whose color to use.
  final String? series;

  /// A red dot on the last point.
  final bool ends;

  /// Small marks on the lowest and highest points.
  final bool extremes;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  /// Hover and arrow keys show a tooltip.
  final bool interactive;

  /// The width on its own (upstream `w-28`); `double.infinity` fills the
  /// parent's width.
  final double width;

  /// The height on its own (upstream `h-10`); `double.infinity` fills the
  /// parent's height.
  final double height;

  static const int _maxPoints = 600;

  @override
  ChartConfig autoConfig() => const {};

  @override
  bool get legendByDefault => false;

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) => const [];

  @override
  Widget buildStandalone(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ChartContainer(
      config: config ?? const {},
      aspectRatio: null,
      children: [
        this,
        if (interactive && tooltip) const ChartTooltip(),
      ],
    ),
  );

  List<double?> get _values {
    final all = [
      for (final d in data)
        switch (d) {
          final Map<String, Object?> row => toNum(row[dataKey ?? 'value']),
          _ => toNum(d),
        },
    ];
    if (all.length <= _maxPoints) return all;
    final points = [
      for (final (i, v) in all.indexed) (i.toDouble(), v ?? 0.0),
    ];
    return [for (final i in lttb(points, _maxPoints)) all[i]];
  }

  String _category(int index) {
    final key = xKey;
    final row = data.elementAtOrNull(index);
    if (key != null && row is Map<String, Object?>) {
      return jsString(row[key] ?? index + 1);
    }
    return 'Point ${index + 1}';
  }

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final values = _values;
    final format = valueFormatter ?? formatNumber;
    final own = switch (series) {
      final key? => scope.keys.indexOf(key),
      null => -1,
    };
    final sl = slot ?? math.max(0, own);
    final real = [
      for (final v in values)
        if (v != null && isNum(v)) v,
    ];
    final lo = switch (real.isEmpty) {
      true => 0.0,
      false => real.reduce(math.min),
    };
    final hi = switch (real.isEmpty) {
      true => 1.0,
      false => real.reduce(math.max),
    };
    final bars = variant == SparkVariant.bar;
    final pad = switch (bars) {
      true => 0.0,
      false =>
        (switch (hi - lo) {
              0 => 1.0,
              final span => span,
            }) *
            0.04,
    };
    final spec = SparkSpec(
      variant: variant,
      values: values,
      min: switch (bars) {
        true => math.min(0, lo),
        false => lo - pad,
      },
      max: hi + pad,
      slot: sl,
      ends: ends,
      extremes: extremes,
      state: switch (real.isEmpty) {
        true => ChartState.empty,
        false => ChartState.ready,
      },
    );
    final name = label ?? 'Trend';
    return ChartCanvas<SparkSpec>(
      recipe: chartSparkRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: name,
      summary: _summary(name, real, format),
      table: switch (interactive) {
        false => null,
        true => TableModel(
          head: [xKey ?? 'Point', dataKey ?? 'Value'],
          rows: [
            for (final (i, v) in values.take(tableRowCap).indexed)
              [
                _category(i),
                switch (v) {
                  final n? when isNum(n) => format(n),
                  _ => '',
                },
              ],
          ],
          clipped: switch (values.length > tableRowCap) {
            true => (shown: tableRowCap, total: values.length),
            false => null,
          },
        ),
      },
      describe: (index, _, _) {
        final v = values.elementAtOrNull(index);
        if (v == null || !isNum(v)) return null;
        final row = data.elementAtOrNull(index);
        return ChartDescribed(
          label: _category(index),
          payload: [
            ChartTooltipItem(
              dataKey: dataKey ?? 'value',
              name: name,
              value: v,
              payload: switch (row) {
                final Map<String, Object?> map => map,
                _ => null,
              },
              slot: sl,
              kind: XYKind.line,
            ),
          ],
          announce: '${_category(index)}: ${format(v)}',
        );
      },
      interactive: interactive && spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onSelect: onSelect,
    );
  }

  String _summary(String name, List<double> real, ChartValueFormatter format) {
    if (real.isEmpty) return '$name: no data.';
    final first = real.first;
    final last = real.last;
    final trend = switch (real.length > 1) {
      false => 'flat',
      true when last > first => 'rising',
      true when last < first => 'falling',
      true => 'flat',
    };
    return '$name: ${real.length} points from ${format(first)} to ${format(last)}, lowest ${format(real.reduce(math.min))}, highest ${format(real.reduce(math.max))}, $trend.';
  }
}
