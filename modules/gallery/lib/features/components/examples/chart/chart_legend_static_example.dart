import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

class ChartLegendStaticExample extends StatelessWidget {
  const ChartLegendStaticExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Legend - Plain Key')),
              CardDescription(Text('A legend that only names the series.')),
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
                  showYAxis: false,
                  label: 'Visitors per month, by device',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(labelFormatter: monthOfRow),
                ),
                ChartLegend(toggle: false),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
