import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// How a tooltip row marks its series.
enum ChartTooltipIndicator {
  /// A swatch chip (a line sample for line series).
  dot,

  /// A narrow bar beside the row.
  line,

  /// A dashed rule beside the row.
  dashed,
}

/// Replaces a tooltip label.
typedef ChartTooltipLabelFormatter =
    Widget Function(
      String label,
      List<ChartTooltipItem> payload,
    );

/// Replaces a whole tooltip row.
typedef ChartTooltipFormatter =
    Widget Function(
      Object? value,
      String name,
      ChartTooltipItem item,
      int index,
      ChartRow? payload,
    );

/// The tooltip's slip of paper: a label in the script hand and one row
/// per series with a swatch that matches the drawing, the series name and
/// its value.
///
/// It reads the active point from [ChartTooltipPayload]; pass [label] and
/// [payload] to show it anywhere else.
///
/// Mirrors `ChartTooltipContent` in upstream `src/components/ui/chart.tsx`.
class ChartTooltipContent extends StatelessWidget {
  const ChartTooltipContent({
    super.key,
    this.label,
    this.payload,
    this.indicator = ChartTooltipIndicator.dot,
    this.hideLabel = false,
    this.hideIndicator = false,
    this.nameKey,
    this.labelKey,
    this.color,
    this.labelFormatter,
    this.formatter,
  });

  /// The label; the active point's by default.
  final String? label;

  /// The rows; the active point's by default.
  final List<ChartTooltipItem>? payload;

  /// How rows mark their series.
  final ChartTooltipIndicator indicator;

  /// Leaves out the label.
  final bool hideLabel;

  /// Leaves out the swatches.
  final bool hideIndicator;

  /// Which config entry names a row.
  final String? nameKey;

  /// Which config entry names the label.
  final String? labelKey;

  /// Forces the indicator color of rows without a slot.
  final Color? color;

  /// Changes the label.
  final ChartTooltipLabelFormatter? labelFormatter;

  /// Replaces whole rows.
  final ChartTooltipFormatter? formatter;

  @override
  Widget build(BuildContext context) {
    final scoped = ChartTooltipPayload.maybeOf(context);
    final rows = payload ?? scoped?.payload ?? const [];
    if (rows.isEmpty) return const SizedBox.shrink();
    final config = ChartScope.maybeOf(context)?.config ?? const {};
    final theme = LooseleafTheme.of(context);
    final title = _label(
      context,
      config,
      label ?? scoped?.label ?? '',
      rows,
    );
    final nest = rows.length == 1 && indicator != ChartTooltipIndicator.dot;
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: Spacing.d128),
        child: Paper(
          stock: StockName.slip,
          edge: const EdgeSpec.all(EdgeKind.cut),
          tiltDegrees: 0.7,
          seed: 'chart-tooltip',
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d12,
            vertical: Spacing.d8,
          ),
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 13,
              color: theme.colors.ink,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d6,
              children: [
                if (title != null && !nest) title,
                for (final (index, item) in rows.indexed)
                  _row(context, config, item, index, switch (nest) {
                    true => title,
                    false => null,
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _label(
    BuildContext context,
    ChartConfig config,
    String text,
    List<ChartTooltipItem> rows,
  ) {
    if (hideLabel) return null;
    final first = rows.first;
    final key = labelKey ?? first.dataKey ?? first.name ?? 'value';
    final value = switch (labelKey) {
      null => config[text]?.label ?? text,
      _ => config[key]?.label ?? text,
    };
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: 18,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
      color: theme.colors.ink,
    );
    if (labelFormatter case final format?) {
      return DefaultTextStyle.merge(style: style, child: format(value, rows));
    }
    if (value.isEmpty) return null;
    return Text(value, style: style);
  }

  Widget _row(
    BuildContext context,
    ChartConfig config,
    ChartTooltipItem item,
    int index,
    Widget? nestedLabel,
  ) {
    final name = item.name;
    if (formatter case final format? when item.value != null && name != null) {
      return format(item.value, name, item, index, item.payload);
    }
    final theme = LooseleafTheme.of(context);
    final key = nameKey ?? item.name ?? item.dataKey ?? 'value';
    final itemConfig = config[key] ?? config[item.dataKey];
    final rowName = itemConfig?.label ?? item.name ?? '';
    final value = item.value;
    const tabular = [FontFeature.tabularFigures()];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: switch (indicator) {
          ChartTooltipIndicator.dot => CrossAxisAlignment.center,
          _ => CrossAxisAlignment.stretch,
        },
        spacing: Spacing.d8,
        children: [
          ?_indicator(context, itemConfig, item),
          Expanded(
            child: Row(
              crossAxisAlignment: switch (nestedLabel) {
                null => CrossAxisAlignment.center,
                _ => CrossAxisAlignment.end,
              },
              spacing: Spacing.d16,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d6,
                    children: [
                      ?nestedLabel,
                      Text(
                        rowName,
                        style: TextStyle(
                          height: 1,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (value != null)
                  Text.rich(
                    TextSpan(
                      text: switch (value) {
                        final num number => formatNumber(number.toDouble()),
                        _ => '$value',
                      },
                      children: [
                        if (item.unit case final unit?)
                          TextSpan(
                            text: unit,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: theme.colors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                    style: TextStyle(
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                      fontFeatures: tabular,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _indicator(
    BuildContext context,
    ChartSeriesConfig? itemConfig,
    ChartTooltipItem item,
  ) {
    if (itemConfig?.icon case final icon?) {
      return SizedBox.square(dimension: Spacing.d10, child: icon);
    }
    if (hideIndicator) return null;
    final colors = LooseleafTheme.of(context).colors;
    final tint = color ?? item.color ?? colors.ink;
    if (indicator == ChartTooltipIndicator.dashed) {
      return SizedBox(
        width: Spacing.d3,
        child: CustomPaint(painter: _DashedRule(tint)),
      );
    }
    if (item.slot case final slot?) {
      return switch (indicator) {
        ChartTooltipIndicator.line => SizedBox(
          width: Spacing.d6,
          child: ChartSwatch(
            palette: slot,
            pattern: item.pattern ?? FillPattern.solid,
            height: double.infinity,
          ),
        ),
        _ => ChartSwatch(
          palette: slot,
          pattern: item.pattern ?? FillPattern.solid,
          marker: item.marker,
          line: item.kind == XYKind.line,
        ),
      };
    }
    return SizedBox.square(
      dimension: Spacing.d10,
      child: ColoredBox(color: tint),
    );
  }
}

/// Upstream's `border-[1.5px] border-dashed` indicator rule.
class _DashedRule extends CustomPainter {
  const _DashedRule(this.color);

  final Color color;

  static const double _dash = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final x = size.width / 2;
    for (var y = 0.0; y < size.height; y += _dash * 2) {
      final end = switch (y + _dash > size.height) {
        true => size.height,
        false => y + _dash,
      };
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRule oldDelegate) => oldDelegate.color != color;
}
