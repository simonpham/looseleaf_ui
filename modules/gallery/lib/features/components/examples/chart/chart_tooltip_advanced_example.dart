import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'running': ChartSeriesConfig(label: 'Running'),
  'swimming': ChartSeriesConfig(label: 'Swimming'),
};

class ChartTooltipAdvancedExample extends StatelessWidget {
  const ChartTooltipAdvancedExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Tooltip - Advanced')),
              CardDescription(Text('Tooltip with custom formatter and total.')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                const BarChart(
                  data: activity,
                  xKey: 'date',
                  xFormatter: weekday,
                  stacked: true,
                  showYAxis: false,
                  label: 'Calories burned per session',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(
                    hideLabel: true,
                    formatter: (value, name, item, index, _) => _AdvancedRow(
                      name: name,
                      value: value,
                      item: item,
                      total: index == 1,
                    ),
                  ),
                  defaultIndex: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _AdvancedRow extends StatelessWidget {
  const _AdvancedRow({
    required this.name,
    required this.value,
    required this.item,
    required this.total,
  });

  final String name;
  final Object? value;
  final ChartTooltipItem item;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final row = item.payload ?? const {};
    final sum = (row['running'] as num? ?? 0) + (row['swimming'] as num? ?? 0);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: Spacing.d176),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d6,
        children: [
          Row(
            spacing: Spacing.d8,
            children: [
              ChartSwatch(
                palette: item.slot ?? 0,
                pattern: item.pattern ?? FillPattern.solid,
              ),
              Expanded(child: Text(name)),
              _Kcal(value: value),
            ],
          ),
          if (total) const Separator(variant: SeparatorVariant.dashed),
          if (total)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: theme.typography
                        .interface(cssSize: 12, color: theme.colors.ink)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                _Kcal(value: sum),
              ],
            ),
        ],
      ),
    );
  }
}

class _Kcal extends StatelessWidget {
  const _Kcal({required this.value});

  final Object? value;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text.rich(
      TextSpan(
        text: jsString(value),
        style: theme.typography.mono(
          cssSize: 12,
          fontWeight: FontWeight.w500,
          color: theme.colors.ink,
        ),
        children: [
          TextSpan(
            text: ' kcal',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
