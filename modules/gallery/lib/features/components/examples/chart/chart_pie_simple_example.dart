import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'chrome': ChartSeriesConfig(label: 'Chrome'),
  'safari': ChartSeriesConfig(label: 'Safari'),
  'firefox': ChartSeriesConfig(label: 'Firefox'),
  'edge': ChartSeriesConfig(label: 'Edge'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartPieSimpleExample extends StatelessWidget {
  const ChartPieSimpleExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Pie Chart')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Spacing.d256 + Spacing.d24,
                ),
                child: const ChartContainer(
                  config: _config,
                  aspectRatio: 1,
                  children: [
                    PieChart(
                      data: browsers,
                      nameKey: 'browser',
                      valueKey: 'visitors',
                      showLabels: false,
                      label: 'Visitors by browser',
                    ),
                    ChartTooltip(content: ChartTooltipContent(hideLabel: true)),
                  ],
                ),
              ),
            ),
          ),
          const ChartTrendFooter(
            caption: 'Showing total visitors for the last 6 months',
          ),
        ],
      ),
    ),
  );
}
