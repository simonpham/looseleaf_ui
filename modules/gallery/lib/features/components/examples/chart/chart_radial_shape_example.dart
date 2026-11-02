import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ChartRadialShapeExample extends StatelessWidget {
  const ChartRadialShapeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
        child: Card(
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Radial Chart - Shape')),
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
                    config: {
                      'safari': ChartSeriesConfig(
                        label: 'Safari',
                        color: theme.colors.inkYou,
                      ),
                    },
                    aspectRatio: 1,
                    children: [
                      RadialChart(
                        data: [
                          {'browser': 'safari', 'visitors': 1260},
                        ],
                        nameKey: 'browser',
                        valueKey: 'visitors',
                        max: 1500,
                        endAngle: 270,
                        centerLabel: (_) => const ChartCenterLabel(
                          value: '1,260',
                          label: 'Visitors',
                        ),
                        label: 'Safari visitors against a goal of 1,500',
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
}
