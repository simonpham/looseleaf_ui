import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'running': ChartSeriesConfig(label: 'Running'),
  'swimming': ChartSeriesConfig(label: 'Swimming'),
};

class ChartTooltipDefaultExample extends StatelessWidget {
  const ChartTooltipDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Tooltip - Default')),
              CardDescription(
                Text('Default tooltip with ChartTooltipContent.'),
              ),
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
                ChartTooltip(content: ChartTooltipContent(), defaultIndex: 1),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
