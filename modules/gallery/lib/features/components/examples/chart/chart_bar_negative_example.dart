import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'gain': ChartSeriesConfig(label: 'Gain'),
  'loss': ChartSeriesConfig(label: 'Loss'),
};

class ChartBarNegativeExample extends StatelessWidget {
  const ChartBarNegativeExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Bar Chart - Negative')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: swingColumns,
                  xKey: 'month',
                  xFormatter: short,
                  series: ['gain', 'loss'],
                  stacked: true,
                  label: 'Change in visitors per month',
                ),
                const ChartTooltip(
                  content: ChartTooltipContent(hideLabel: true),
                ),
                const ChartLegend(),
              ],
            ),
          ),
          const ChartTrendFooter(
            caption: 'Showing total visitors for the last 6 months',
          ),
        ],
      ),
    ),
  );
}
