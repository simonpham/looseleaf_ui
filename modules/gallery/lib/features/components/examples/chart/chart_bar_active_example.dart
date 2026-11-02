import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'visitors': ChartSeriesConfig(label: 'Visitors'),
};

class ChartBarActiveExample extends StatelessWidget {
  const ChartBarActiveExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Bar Chart - Active')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: browsersActive,
                  xKey: 'browser',
                  showYAxis: false,
                  highlights: [ChartHighlight(from: 'firefox', to: 'firefox')],
                  label: 'Visitors by browser',
                ),
                ChartTooltip(
                  content: ChartTooltipContent(hideLabel: true),
                  defaultIndex: 2,
                ),
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
