import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ChartRadialTextExample extends StatelessWidget {
  const ChartRadialTextExample({super.key});

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
                CardTitle(Text('Radial Chart - Text')),
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
                          {'browser': 'safari', 'visitors': 200},
                        ],
                        nameKey: 'browser',
                        valueKey: 'visitors',
                        max: 250,
                        startAngle: 0,
                        endAngle: 360,
                        centerLabel: (_) => const ChartCenterLabel(
                          value: '200',
                          label: 'Visitors',
                        ),
                        label: 'Safari visitors against a goal of 250',
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
