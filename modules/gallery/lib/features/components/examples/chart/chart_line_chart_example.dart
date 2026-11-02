import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _visitors = <ChartRow>[
  {'month': 'Jan', 'desktop': 186, 'mobile': 80, 'tablet': 40},
  {'month': 'Feb', 'desktop': 305, 'mobile': 200, 'tablet': 66},
  {'month': 'Mar', 'desktop': 237, 'mobile': 120, 'tablet': 90},
  {'month': 'Apr', 'desktop': 73, 'mobile': 190, 'tablet': 84},
  {'month': 'May', 'desktop': 209, 'mobile': 130, 'tablet': 72},
  {'month': 'Jun', 'desktop': 214, 'mobile': 140, 'tablet': 110},
];

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
  'tablet': ChartSeriesConfig(label: 'Tablet'),
};

class ChartLineChartExample extends StatelessWidget {
  const ChartLineChartExample({super.key});

  @override
  Widget build(BuildContext context) => const ChartContainer(
    config: _config,
    height: Spacing.d288,
    children: [
      LineChart(
        data: _visitors,
        xKey: 'month',
        label: 'Visitors by device, January to June',
        annotations: [
          ChartAnnotation(
            at: 'max',
            series: 'desktop',
            text: 'launch',
            pen: NotePen.red,
          ),
        ],
      ),
      ChartTooltip(
        content: ChartTooltipContent(indicator: ChartTooltipIndicator.line),
      ),
      ChartLegend(),
    ],
  );
}
