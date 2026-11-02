import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartLegendKeysExample extends StatelessWidget {
  const ChartLegendKeysExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Legend - Keys')),
              CardDescription(
                Text('Only the series you name, in the order you name them.'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: visitorsThree,
                  xKey: 'month',
                  xFormatter: short,
                  showYAxis: false,
                  label: 'Visitors per month, by device',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(labelFormatter: monthOfRow),
                ),
                ChartLegend(keys: ['mobile', 'desktop']),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
