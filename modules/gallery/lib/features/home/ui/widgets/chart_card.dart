import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A clipped card with this week's signups as bars, the record circled.
///
/// Mirrors upstream `src/docs/content/home/chart-card.tsx`.
class ChartCard extends StatelessWidget {
  const ChartCard({super.key});

  static const List<ChartRow> _signups = [
    {'day': 'Mon', 'signups': 42},
    {'day': 'Tue', 'signups': 58},
    {'day': 'Wed', 'signups': 35},
    {'day': 'Thu', 'signups': 71},
    {'day': 'Fri', 'signups': 64},
    {'day': 'Sat', 'signups': 30},
    {'day': 'Sun', 'signups': 22},
  ];

  static const double _chartHeight = 224;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Card(
      fastener: FastenerKind.clip,
      seed: 'home-chart',
      gap: Spacing.d12,
      children: [
        const CardHeader(
          children: [
            CardTitle(Text('Signups')),
            CardDescription(Text('This week. The record is circled.')),
          ],
        ),
        CardContent(
          child: SizedBox(
            height: _chartHeight,
            child: ChartContainer(
              config: {
                'signups': ChartSeriesConfig(
                  label: 'Signups',
                  color: colors.green,
                ),
              },
              aspectRatio: null,
              children: const [
                BarChart(
                  data: _signups,
                  xKey: 'day',
                  label: 'Signups per day this week',
                  seed: 'home-chart',
                  annotations: [
                    ChartAnnotation(
                      at: 'max',
                      text: 'launch day!',
                      pen: NotePen.blue,
                    ),
                  ],
                ),
                ChartTooltip(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
