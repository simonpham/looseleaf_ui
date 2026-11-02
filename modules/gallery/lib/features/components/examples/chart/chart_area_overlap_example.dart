import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

class ChartAreaOverlapExample extends StatelessWidget {
  const ChartAreaOverlapExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Area Chart - Overlap')),
              CardDescription(
                Text('Showing total visitors for the last 6 months'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                AreaChart(
                  data: visitors,
                  xKey: 'month',
                  xFormatter: short,
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
          ChartTrendFooter(caption: 'January - June 2024'),
        ],
      ),
    ),
  );
}
