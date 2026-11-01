import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _traffic = <ChartRow>[
  {'month': 'Jan', 'direct': 186, 'search': 80, 'social': 40},
  {'month': 'Feb', 'direct': 305, 'search': 200, 'social': 66},
  {'month': 'Mar', 'direct': 237, 'search': 120, 'social': 90},
  {'month': 'Apr', 'direct': 73, 'search': 190, 'social': 84},
  {'month': 'May', 'direct': 209, 'search': 130, 'social': 72},
  {'month': 'Jun', 'direct': 214, 'search': 140, 'social': 110},
];

const _config = {
  'direct': ChartSeriesConfig(label: 'Direct'),
  'search': ChartSeriesConfig(label: 'Search'),
  'social': ChartSeriesConfig(label: 'Social'),
};

class ChartAreaChartExample extends StatelessWidget {
  const ChartAreaChartExample({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    seed: 'area',
    children: [
      CardHeader(
        children: [
          CardTitle(Text('Traffic by source')),
          CardDescription(Text('Visits per month, stacked')),
        ],
      ),
      CardContent(
        child: ChartContainer(
          config: _config,
          height: Spacing.d256,
          children: [
            AreaChart(
              data: _traffic,
              xKey: 'month',
              stacked: true,
              label: 'Visits by source, January to June',
            ),
            ChartTooltip(content: ChartTooltipContent()),
            ChartLegend(),
          ],
        ),
      ),
    ],
  );
}
