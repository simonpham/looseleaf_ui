import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The frame around a chart, its legend and its tooltip. It owns the
/// [config] (a key's position is its palette slot, a `color` repaints that
/// slot), which series are switched off, and the cursor the chart, the
/// tooltip and the legend share.
///
/// Lay the parts out as [children], like shadcn's: the chart (it takes the
/// room left), a [ChartTooltip] to switch the tooltip on, and a
/// [ChartLegend] before or after it. The frame is [aspectRatio] (16:9, like
/// `aspect-video`) of the width, or [height] tall.
///
/// ```dart
/// ChartContainer(
///   config: const {'sales': ChartSeriesConfig(label: 'Sales')},
///   height: 256,
///   children: [
///     BarChart(data: sales, xKey: 'day'),
///     const ChartTooltip(),
///   ],
/// )
/// ```
///
/// Mirrors `ChartContainer` in upstream `src/components/ui/chart.tsx`.
class ChartContainer extends StatefulWidget {
  const ChartContainer({
    super.key,
    required this.config,
    required this.children,
    this.patterns,
    this.hiddenSeries,
    this.defaultHiddenSeries = const [],
    this.onHiddenSeriesChange,
    this.aspectRatio = 16 / 9,
    this.height,
  });

  /// The series, in palette order.
  final ChartConfig config;

  /// The chart, its [ChartTooltip] and its [ChartLegend].
  final List<Widget> children;

  /// Pencil patterns besides color; off by default, automatic in high
  /// contrast.
  final ChartPatterns? patterns;

  /// The series switched off, controlled.
  final List<String>? hiddenSeries;

  /// The series switched off at first, uncontrolled.
  final List<String> defaultHiddenSeries;

  /// A legend entry was pressed.
  final ValueChanged<List<String>>? onHiddenSeriesChange;

  /// Width over height; ignored when [height] is set. Null fills the
  /// parent's height.
  final double? aspectRatio;

  /// A fixed height.
  final double? height;

  @override
  State<ChartContainer> createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  final ChartController _controller = ChartController();
  late List<String> _hidden = [...widget.defaultHiddenSeries];

  List<String> get _hiddenList => widget.hiddenSeries ?? _hidden;

  void _toggle(String key) {
    final current = _hiddenList;
    final next = switch (current.contains(key)) {
      true => [
        for (final k in current)
          if (k != key) k,
      ],
      false => [...current, key],
    };
    if (widget.hiddenSeries == null) setState(() => _hidden = next);
    widget.onHiddenSeriesChange?.call(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    final patterns =
        widget.patterns ??
        switch (highContrast) {
          true => ChartPatterns.auto,
          false => ChartPatterns.off,
        };
    final chart = widget.children.whereType<ChartWidget>().firstOrNull;
    final tooltip = widget.children.whereType<ChartTooltip>().firstOrNull;
    return LooseleafTheme(
      data: theme.copyWith(colors: _slotColors(theme.colors)),
      child: ChartScope(
        config: widget.config,
        hidden: {..._hiddenList},
        toggle: _toggle,
        patterns: patterns,
        controller: _controller,
        tooltip: tooltip,
        legend: chart?.legendEntries(widget.config, patterns) ?? const [],
        child: DefaultTextStyle.merge(
          style: theme.typography.interface(cssSize: 12),
          child: LayoutBuilder(builder: _frame),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height =
        widget.height ??
        switch (widget.aspectRatio) {
          final ratio? when width.isFinite => width / ratio,
          _ => constraints.maxHeight,
        };
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final child in widget.children)
            switch (child) {
              ChartWidget() => Expanded(child: child),
              ChartTooltip() => const SizedBox.shrink(),
              _ => child,
            },
        ],
      ),
    );
  }

  /// Puts each configured color on its slot's paint, like upstream's
  /// `--ll-<slot>: var(--color-<key>)`.
  LooseleafColors _slotColors(LooseleafColors colors) {
    var out = colors;
    for (final (index, entry) in widget.config.values.indexed) {
      final color = entry.color;
      if (color == null) continue;
      out = switch (slotKey(index)) {
        PaintKey.marker => out.copyWith(marker: color),
        PaintKey.inkYou => out.copyWith(inkYou: color),
        PaintKey.green => out.copyWith(green: color),
        PaintKey.hiDeep => out.copyWith(hiDeep: color),
        PaintKey.grape => out.copyWith(grape: color),
        PaintKey.red => out.copyWith(red: color),
        PaintKey.pencil => out.copyWith(pencil: color),
        PaintKey.orangeText => out.copyWith(orangeText: color),
        _ => out,
      };
    }
    return out;
  }
}
