import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
  'other': ChartSeriesConfig(label: 'Other'),
};

class ChartAreaStackedExpandExample extends StatelessWidget {
  const ChartAreaStackedExpandExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Area Chart - Stacked Expanded')),
              CardDescription(
                Text('Share of the month\'s visitors, in percent'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                AreaChart(
                  data: visitorsShare,
                  xKey: 'month',
                  xFormatter: short,
                  series: ['other', 'mobile', 'desktop'],
                  stacked: true,
                  yDomain: (0, 100),
                  yFormatter: (v) => '${formatNumber(v)}%',
                  label: 'Share of visitors by device, per month',
                ),
                const ChartTooltip(
                  content: ChartTooltipContent(
                    indicator: ChartTooltipIndicator.line,
                    labelFormatter: monthOfRow,
                  ),
                ),
                const ChartLegend(),
              ],
            ),
          ),
          const ChartTrendFooter(caption: 'January - June 2024'),
        ],
      ),
    ),
  );
}
