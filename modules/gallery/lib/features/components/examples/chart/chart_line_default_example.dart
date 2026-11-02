import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
};

class ChartLineDefaultExample extends StatelessWidget {
  const ChartLineDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Card(
        fastener: FastenerKind.clip,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Line Chart')),
              CardDescription(Text('January - June 2024')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                LineChart(
                  data: desktopOnly,
                  xKey: 'month',
                  xFormatter: short,
                  dots: false,
                  annotations: [
                    const ChartAnnotation(
                      at: 'min',
                      text: 'quiet April',
                      pen: NotePen.red,
                    ),
                  ],
                  showYAxis: false,
                  label: 'Desktop visitors per month',
                ),
                const ChartTooltip(
                  content: ChartTooltipContent(hideLabel: true),
                ),
              ],
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
