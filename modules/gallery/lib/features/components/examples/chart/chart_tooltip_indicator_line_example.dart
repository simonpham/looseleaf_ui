import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'running': ChartSeriesConfig(label: 'Running'),
  'swimming': ChartSeriesConfig(label: 'Swimming'),
};

class ChartTooltipIndicatorLineExample extends StatelessWidget {
  const ChartTooltipIndicatorLineExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Tooltip - Line Indicator')),
              CardDescription(Text('Tooltip with line indicator.')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: activity,
                  xKey: 'date',
                  xFormatter: weekday,
                  stacked: true,
                  showYAxis: false,
                  label: 'Calories burned per session',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(
                    indicator: ChartTooltipIndicator.line,
                  ),
                  defaultIndex: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
