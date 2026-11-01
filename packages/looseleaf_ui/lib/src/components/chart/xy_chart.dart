import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// What bar, line, area and scatter charts share: rows, the category key,
/// the series and how they are drawn, axes, gridlines, annotations,
/// reference lines and highlights.
///
/// Mirrors `XYChartProps` and `XYChartBody` in upstream
/// `src/components/ui/chart.tsx`.
abstract class XYChart extends ChartWidget {
  const XYChart({
    super.key,
    required this.data,
    this.xKey,
    this.series,
    this.kinds,
    this.stacked = false,
    this.curve,
    this.yDomain,
    this.xDomain,
    this.zero,
    this.xFormatter,
    this.yFormatter,
    this.valueFormatter,
    this.dots,
    this.showValues,
    this.sizeKey,
    this.showGrid = true,
    this.showXAxis = true,
    this.showYAxis = true,
    this.annotations = const [],
    this.references = const [],
    this.highlights = const [],
    this.xLabel,
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

  /// One row per category (per point for a scatter).
  final List<ChartRow> data;

  /// The category key (a scatter's x number); the first text key by
  /// default.
  final String? xKey;

  /// The keys to draw, in stacking order; the config's numeric keys, else
  /// the data's, by default.
  final List<String>? series;

  /// Mixes marks: `{'revenue': XYKind.bar, 'target': XYKind.line}`.
  final Map<String, XYKind>? kinds;

  /// Stacks bars (or areas).
  final bool stacked;

  /// How lines and areas join their points; smooth by default.
  final CurveKind? curve;

  /// Pins the value axis; a null end picks a tidy one.
  final AxisDomain? yDomain;

  /// Pins a scatter's x axis.
  final AxisDomain? xDomain;

  /// Whether the value axis includes zero; yes for bars and areas.
  final bool? zero;

  /// Text of a category on the axis.
  final CategoryFormat? xFormatter;

  /// Text of an axis tick; compact numbers by default.
  final ChartValueFormatter? yFormatter;

  /// Text of the numbers on bars, in the tooltip, summary and table.
  final ChartValueFormatter? valueFormatter;

  /// Point markers on lines: on, off, or automatic when null.
  final bool? dots;

  /// Numbers on bars: on, off, or automatic when null.
  final bool? showValues;

  /// The key that sizes a scatter's bubbles.
  final String? sizeKey;

  /// Broken pencil rules across the plot.
  final bool showGrid;

  /// Category axis labels.
  final bool showXAxis;

  /// Value axis labels.
  final bool showYAxis;

  /// Hand-circled call-outs.
  final List<ChartAnnotation> annotations;

  /// Dashed goal lines.
  final List<ChartReference> references;

  /// Stretches marked with a highlighter.
  final List<ChartHighlight> highlights;

  /// The name of the category column in the data table.
  final String? xLabel;

  /// How the series are drawn unless [kinds] says otherwise.
  XYKind get kind;

  /// Bars run sideways.
  bool get horizontal => false;

  String get _xKey => xKey ?? ChartKeys.xKey(data);

  List<String> _keys(ChartConfig? config) =>
      series ?? ChartKeys.series(data, _xKey, config);

  List<SeriesInput> _inputs(ChartConfig config) => [
    for (final (index, key) in _keys(config).indexed)
      SeriesInput(
        key,
        name: ChartKeys.label(config, key),
        slot: ChartKeys.slot(config, key, index),
        kind: kinds?[key],
        pattern: config[key]?.pattern,
        marker: config[key]?.marker,
        dash: config[key]?.dash,
      ),
  ];

  @override
  ChartConfig autoConfig() => {
    for (final key in _keys(config)) key: ChartSeriesConfig(label: key),
  };

  @override
  bool get legendByDefault => _keys(config).length > 1;

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) {
    final inputs = _inputs(config);
    return [
      for (final s in inputs) _entry(s, inputs.length, patterns),
    ];
  }

  ChartLegendEntry _entry(SeriesInput s, int count, ChartPatterns patterns) {
    final drawn = s.kind ?? kind;
    final slot = s.slot ?? 0;
    final look = seriesLook(
      drawn,
      slot,
      count,
      patterns.look,
      pattern: s.pattern,
      marker: s.marker,
      dash: s.dash,
    );
    return ChartLegendEntry(
      key: s.key,
      slot: slot,
      pattern: look.pattern,
      marker: look.marker,
      dash: look.dash,
      kind: drawn,
    );
  }

  static const Map<XYKind, String> _nouns = {
    XYKind.bar: 'Bar chart',
    XYKind.line: 'Line chart',
    XYKind.area: 'Area chart',
    XYKind.scatter: 'Scatter chart',
  };

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final xk = _xKey;
    final built = buildXYRows(
      XYBuildInput(
        rows: data,
        xKey: xk,
        series: _inputs(scope.config),
        kind: kind,
        stacked: stacked,
        horizontal: horizontal,
        curve: curve,
        domain: yDomain,
        xDomain: xDomain,
        zero: zero,
        xFormat: xFormatter,
        yFormat: yFormatter,
        valueFormat: valueFormatter,
        dots: dots,
        values: showValues,
        grid: showGrid,
        showX: showXAxis,
        showY: showYAxis,
        notes: annotations,
        refs: references,
        bands: highlights,
        patterns: scope.patterns.look,
        hidden: scope.hidden,
        state: switch (loading) {
          true => ChartState.loading,
          false => null,
        },
        stateText: switch (loading) {
          true => 'Loading',
          false => emptyText,
        },
        sizeKey: sizeKey,
      ),
    );
    final spec = built.spec;
    final rows = built.rows;
    final format = valueFormatter ?? formatNumber;
    final noun = switch (spec.series.any((s) => s.kind != kind)) {
      true => 'Chart',
      false => _nouns[kind] ?? 'Chart',
    };
    final extra = switch (description) {
      final text? => ' $text',
      null => '',
    };
    final summary =
        '${summarizeXY(spec, kind: noun, title: label, format: format)}$extra';
    final table = tableXY(
      spec,
      format: format,
      xHead: xLabel ?? xk,
      xFormat: switch (xFormatter) {
        final f? => (v) => f(v, 0),
        null => null,
      },
    );
    final scatter = kind == XYKind.scatter;
    return ChartCanvas<XYSpec>(
      recipe: chartXYRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: label ?? noun,
      summary: summary,
      table: table,
      describe: (index, series, layout) => switch (scatter) {
        true => _describePoint(spec, rows, index, layout, format, xk),
        false => _describeRow(spec, rows, index, series, format),
      },
      seriesCount: switch (!scatter && spec.series.length > 1) {
        true => spec.series.length,
        false => 0,
      },
      interactive: spec.state == ChartState.ready,
      animate: animate,
      seed: seed,
      onActiveChange: onActiveChange,
      onSelect: onSelect,
    );
  }

  ChartDescribed? _describePoint(
    XYSpec spec,
    List<ChartRow> rows,
    int index,
    ChartLayoutBase layout,
    ChartValueFormatter format,
    String xk,
  ) {
    if (layout is! XYLayout) return null;
    final point = layout.pointOf.elementAtOrNull(index);
    if (point == null) return null;
    final s = spec.series[point.s];
    final x = s.xs?.elementAtOrNull(point.j) ?? 0;
    final xs = switch (xFormatter) {
      final f? => f(x, point.j),
      null => formatNumber(x),
    };
    final y = s.values.elementAtOrNull(point.j);
    final value = switch (y) {
      final v? when isNum(v) => v,
      _ => null,
    };
    return ChartDescribed(
      label: '${xLabel ?? xk} $xs',
      payload: [
        ChartTooltipItem(
          dataKey: s.key,
          name: s.name,
          value: value,
          payload: rows.elementAtOrNull(point.j),
          slot: s.slot,
          pattern: s.pattern,
          marker: s.marker,
          kind: XYKind.scatter,
        ),
      ],
      announce:
          '${s.name}: $xs, ${switch (value) {
            final v? => format(v),
            null => 'no value',
          }}',
    );
  }

  ChartDescribed _describeRow(
    XYSpec spec,
    List<ChartRow> rows,
    int index,
    int? series,
    ChartValueFormatter format,
  ) {
    final row = rows.elementAtOrNull(index);
    final items = [
      for (final s in spec.series)
        if (s.values.elementAtOrNull(index) case final v? when isNum(v))
          ChartTooltipItem(
            dataKey: s.key,
            name: s.name,
            value: v,
            payload: row,
            slot: s.slot,
            pattern: s.pattern,
            marker: s.marker,
            kind: s.kind,
          ),
    ];
    final key = switch (series) {
      final si? => spec.series.elementAtOrNull(si)?.key,
      null => null,
    };
    final spoken = switch (series) {
      null => items,
      _ => [
        for (final item in items)
          if (item.dataKey == key) item,
      ],
    };
    final said = switch (spoken.isEmpty) {
      true => items,
      false => spoken,
    };
    final cat = spec.cats.elementAtOrNull(index) ?? '';
    return ChartDescribed(
      label: cat,
      payload: items,
      announce:
          '$cat: ${said.map((item) => '${item.name} ${format((item.value as num).toDouble())}').join(', ')}',
    );
  }
}
