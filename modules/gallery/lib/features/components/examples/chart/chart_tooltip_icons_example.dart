import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'running': ChartSeriesConfig(label: 'Running', icon: InkIcon('timer')),
  'swimming': ChartSeriesConfig(
    label: 'Swimming',
    icon: InkIcon('audio-waveform'),
  ),
};

class ChartTooltipIconsExample extends StatelessWidget {
  const ChartTooltipIconsExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Tooltip - Icons')),
              CardDescription(Text('Tooltip with icons.')),
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
                  content: ChartTooltipContent(hideLabel: true),
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
