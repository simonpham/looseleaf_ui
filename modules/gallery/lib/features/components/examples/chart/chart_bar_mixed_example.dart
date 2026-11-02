import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'chrome': ChartSeriesConfig(label: 'Chrome'),
  'safari': ChartSeriesConfig(label: 'Safari'),
  'firefox': ChartSeriesConfig(label: 'Firefox'),
  'edge': ChartSeriesConfig(label: 'Edge'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartBarMixedExample extends StatelessWidget {
  const ChartBarMixedExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Bar Chart - Mixed')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: browserColumns,
                  xKey: 'browser',
                  series: [for (final row in browsers) '${row['browser']}'],
                  xFormatter: (value, _) => _config[value]?.label ?? '',
                  stacked: true,
                  horizontal: true,
                  label: 'Visitors by browser',
                ),
                const ChartTooltip(
                  content: ChartTooltipContent(hideLabel: true),
                ),
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
