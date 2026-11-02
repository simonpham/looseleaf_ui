import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
};

class ChartBarHorizontalExample extends StatelessWidget {
  const ChartBarHorizontalExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Bar Chart - Horizontal')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: desktopOnly,
                  xKey: 'month',
                  xFormatter: short,
                  horizontal: true,
                  label: 'Desktop visitors per month',
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
