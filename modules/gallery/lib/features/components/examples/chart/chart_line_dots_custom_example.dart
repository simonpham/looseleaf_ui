import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop', marker: MarkerShape.diamond),
  'mobile': ChartSeriesConfig(label: 'Mobile', marker: MarkerShape.square),
};

class ChartLineDotsCustomExample extends StatelessWidget {
  const ChartLineDotsCustomExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Line Chart - Custom Dots')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                LineChart(
                  data: visitors,
                  xKey: 'month',
                  xFormatter: short,
                  dots: true,
                  showYAxis: false,
                  label: 'Visitors per month, by device',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(labelFormatter: monthOfRow),
                ),
                ChartLegend(),
              ],
            ),
          ),
          ChartTrendFooter(
            caption: 'Showing total visitors for the last 6 months',
          ),
        ],
      ),
    ),
  );
}
