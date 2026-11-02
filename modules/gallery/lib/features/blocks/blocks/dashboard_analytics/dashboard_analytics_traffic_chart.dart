import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Visitors, day by day": this period as an area over the period before
/// as a line, with the best day noted.
class DashboardAnalyticsTrafficChart extends StatelessWidget {
  const DashboardAnalyticsTrafficChart({
    super.key,
    required this.period,
    required this.longName,
  });

  final AnalyticsPeriod period;
  final String longName;

  static const ChartConfig _config = {
    'visitors': ChartSeriesConfig(label: 'This period'),
    'previous': ChartSeriesConfig(label: 'Period before'),
  };

  @override
  Widget build(BuildContext context) {
    final data = <ChartRow>[
      for (final (index, row) in period.rows.indexed)
        {
          'day': row.$1,
          'visitors': row.$2,
          'previous': period.previous.elementAtOrNull(index)?.$2,
        },
    ];
    return Card(
      seed: 'analytics-traffic',
      tape: PaperTape.top,
      tapeKind: TapeKind.washiStripes,
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('Visitors, day by day')),
            CardDescription(
              Text('Every day in $longName, against the days just before'),
            ),
          ],
        ),
        CardContent(
          child: ChartContainer(
            config: _config,
            height: Spacing.d256,
            children: [
              AreaChart(
                data: data,
                xKey: 'day',
                kinds: const {'visitors': XYKind.area, 'previous': XYKind.line},
                xFormatter: (value, _) => analyticsDay('$value'),
                label:
                    'Visitors per day in $longName, compared with the period before',
                annotations: const [
                  ChartAnnotation(
                    at: 'max',
                    text: 'best day',
                    series: 'visitors',
                  ),
                ],
              ),
              ChartTooltip(
                content: ChartTooltipContent(
                  indicator: ChartTooltipIndicator.line,
                  labelFormatter: (label, _) => Text(analyticsDay(label)),
                ),
              ),
              const ChartLegend(),
            ],
          ),
        ),
      ],
    );
  }
}
