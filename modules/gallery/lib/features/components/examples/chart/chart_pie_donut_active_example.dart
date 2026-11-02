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

class ChartPieDonutActiveExample extends StatelessWidget {
  const ChartPieDonutActiveExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Pie Chart - Donut Active')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Spacing.d256 + Spacing.d24,
                ),
                child: ChartContainer(
                  config: _config,
                  aspectRatio: 1,
                  children: [
                    DonutChart(
                      data: browsers,
                      nameKey: 'browser',
                      valueKey: 'visitors',
                      showLabels: false,
                      centerLabel: (info) => ChartCenterLabel(
                        value: switch (info.active) {
                          final slice? => formatNumber(slice.value),
                          null => '',
                        },
                        label: info.active?.name ?? '',
                      ),
                      label: 'Visitors by browser',
                    ),
                    const ChartTooltip(
                      content: ChartTooltipContent(hideLabel: true),
                      defaultIndex: 0,
                    ),
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
