import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'running': ChartSeriesConfig(label: 'Running'),
  'swimming': ChartSeriesConfig(label: 'Swimming'),
};

class ChartTooltipFormatterExample extends StatelessWidget {
  const ChartTooltipFormatterExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Tooltip - Formatter')),
              CardDescription(Text('Tooltip with custom formatter.')),
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
                    formatter: (value, name, _, _, _) =>
                        _KcalRow(name: name, value: value),
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

class _KcalRow extends StatelessWidget {
  const _KcalRow({required this.name, required this.value});

  final String name;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: Spacing.d128),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: Spacing.d8,
        children: [
          Expanded(
            child: Text(
              name,
              style: theme.typography.interface(
                cssSize: 12,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
          _Kcal(value: value),
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
