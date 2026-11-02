import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

class ChartRadarLinesOnlyExample extends StatelessWidget {
  const ChartRadarLinesOnlyExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Radar Chart - Lines Only')),
              CardDescription(
                Text('Showing total visitors for the last 6 months'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d288,
              children: [
                RadarChart(
                  data: radarClose,
                  xKey: 'month',
                  fill: false,
                  label: 'Visitors per month, by device',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(
                    indicator: ChartTooltipIndicator.line,
                  ),
                ),
                ChartLegend(),
              ],
            ),
          ),
          ChartTrendFooter(caption: 'January - June 2024'),
        ],
      ),
    ),
  );
}
