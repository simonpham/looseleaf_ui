import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
};

class ChartRadarDefaultExample extends StatelessWidget {
  const ChartRadarDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        fastener: FastenerKind.clip,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Radar Chart')),
              CardDescription(
                Text('Showing total visitors for the last 6 months'),
              ),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d288,
              children: [
                RadarChart(
                  data: radarDesktop,
                  xKey: 'month',
                  dots: false,
                  label: 'Desktop visitors per month',
                ),
                const ChartTooltip(content: ChartTooltipContent()),
              ],
            ),
          ),
          const ChartTrendFooter(caption: 'January - June 2024'),
        ],
      ),
    ),
  );
}
