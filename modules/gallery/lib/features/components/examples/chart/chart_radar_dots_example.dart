import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
};

class ChartRadarDotsExample extends StatelessWidget {
  const ChartRadarDotsExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Radar Chart - Dots')),
              CardDescription(
                Text('Showing total visitors for the last 6 months'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256 + Spacing.d32,
              children: [
                RadarChart(
                  data: radarDesktop,
                  xKey: 'month',
                  dots: true,
                  label: 'Desktop visitors per month',
                ),
                const ChartTooltip(content: ChartTooltipContent()),
              ],
            ),
          ),
          const ChartTrendFooter(caption: 'January - June 2024'),
        ],
      ),
    ),
  );
}
