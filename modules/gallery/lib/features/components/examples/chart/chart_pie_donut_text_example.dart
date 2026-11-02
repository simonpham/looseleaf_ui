import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

final _total = browsersBig.fold<num>(
  0,
  (sum, row) => sum + (row['visitors'] as num),
);

const _config = {
  'chrome': ChartSeriesConfig(label: 'Chrome'),
  'safari': ChartSeriesConfig(label: 'Safari'),
  'firefox': ChartSeriesConfig(label: 'Firefox'),
  'edge': ChartSeriesConfig(label: 'Edge'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartPieDonutTextExample extends StatelessWidget {
  const ChartPieDonutTextExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Card(
        fastener: FastenerKind.pin,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Pie Chart - Donut with Text')),
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
                      data: browsersBig,
                      nameKey: 'browser',
                      valueKey: 'visitors',
                      showLabels: false,
                      centerLabel: (_) => ChartCenterLabel(
                        value: thousands(_total),
                        label: 'Visitors',
                      ),
                      label: 'Visitors by browser',
                    ),
                    const ChartTooltip(
                      content: ChartTooltipContent(hideLabel: true),
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
