import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

final _cloud = <ChartRow>[
  for (var i = 0; i < 36; i++)
    {
      'height': (20 + i * 2.2 + ((i * 13) % 7)).round(),
      'cats': 30 + i * 1.1 + ((i * 29) % 19),
      'dogs': 24 + i * 0.7 + ((i * 17) % 23),
      'age': 2 + ((i * 5) % 14),
    },
];

const _config = {
  'cats': ChartSeriesConfig(label: 'Cats'),
  'dogs': ChartSeriesConfig(label: 'Dogs'),
};

class ChartScatterChartExample extends StatelessWidget {
  const ChartScatterChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        Expanded(
          child: ChartContainer(
            config: _config,
            height: Spacing.d256,
            children: [
              ScatterChart(
                data: _cloud,
                xKey: 'height',
                series: const ['cats', 'dogs'],
                xLabel: 'Height',
                label: 'Weight by height for cats and dogs',
              ),
              const ChartTooltip(),
              const ChartLegend(),
            ],
          ),
        ),
        Expanded(
          child: ChartContainer(
            config: {
              'cats': ChartSeriesConfig(
                label: 'Cats',
                color: theme.colors.green,
              ),
            },
            height: Spacing.d256,
            children: [
              ScatterChart(
                data: _cloud,
                xKey: 'height',
                series: const ['cats'],
                sizeKey: 'age',
                xLabel: 'Height',
                label: 'Weight by height, sized by age',
              ),
              const ChartTooltip(),
            ],
          ),
        ),
      ],
    );
  }
}
