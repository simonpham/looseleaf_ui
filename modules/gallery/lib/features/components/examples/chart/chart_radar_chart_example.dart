import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _skills = <ChartRow>[
  {'skill': 'Speed', 'ada': 80, 'bo': 50},
  {'skill': 'Power', 'ada': 60, 'bo': 85},
  {'skill': 'Range', 'ada': 90, 'bo': 45},
  {'skill': 'Craft', 'ada': 70, 'bo': 80},
  {'skill': 'Wit', 'ada': 55, 'bo': 90},
  {'skill': 'Luck', 'ada': 65, 'bo': 40},
];

const _config = {
  'ada': ChartSeriesConfig(label: 'Ada'),
  'bo': ChartSeriesConfig(label: 'Bo'),
};

class ChartRadarChartExample extends StatelessWidget {
  const ChartRadarChartExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: const ChartContainer(
        config: _config,
        height: Spacing.d160 * 2,
        children: [
          RadarChart(
            data: _skills,
            xKey: 'skill',
            max: 100,
            label: 'Skills of Ada and Bo',
          ),
          ChartTooltip(
            content: ChartTooltipContent(indicator: ChartTooltipIndicator.line),
          ),
          ChartLegend(),
        ],
      ),
    ),
  );
}
