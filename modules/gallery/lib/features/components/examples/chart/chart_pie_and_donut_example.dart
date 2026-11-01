import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _browsers = <ChartRow>[
  {'browser': 'chrome', 'visitors': 275},
  {'browser': 'safari', 'visitors': 200},
  {'browser': 'firefox', 'visitors': 187},
  {'browser': 'edge', 'visitors': 173},
  {'browser': 'other', 'visitors': 90},
];

const _config = {
  'chrome': ChartSeriesConfig(label: 'Chrome'),
  'safari': ChartSeriesConfig(label: 'Safari'),
  'firefox': ChartSeriesConfig(label: 'Firefox'),
  'edge': ChartSeriesConfig(label: 'Edge'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartPieAndDonutExample extends StatelessWidget {
  const ChartPieAndDonutExample({super.key});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      const Expanded(
        child: ChartContainer(
          config: _config,
          aspectRatio: 1,
          children: [
            PieChart(
              data: _browsers,
              nameKey: 'browser',
              valueKey: 'visitors',
              label: 'Visitors by browser',
            ),
            ChartTooltip(content: ChartTooltipContent(hideLabel: true)),
            ChartLegend(),
          ],
        ),
      ),
      Expanded(
        child: ChartContainer(
          config: _config,
          aspectRatio: 1,
          children: [
            DonutChart(
              data: _browsers,
              nameKey: 'browser',
              valueKey: 'visitors',
              label: 'Visitors by browser, donut',
              centerLabel: (info) => ChartCenterLabel(
                value: formatNumber(info.active?.value ?? info.total),
                label: info.active?.name ?? 'visitors',
              ),
            ),
            const ChartTooltip(content: ChartTooltipContent(hideLabel: true)),
            const ChartLegend(),
          ],
        ),
      ),
    ],
  );
}
