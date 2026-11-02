import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Where they came from": visitors by source in a donut.
class DashboardAnalyticsSourcesChart extends StatelessWidget {
  const DashboardAnalyticsSourcesChart({super.key, required this.period});

  final AnalyticsPeriod period;

  static const ChartConfig _config = {
    'search': ChartSeriesConfig(label: 'Search'),
    'direct': ChartSeriesConfig(label: 'Direct'),
    'social': ChartSeriesConfig(label: 'Social'),
    'referral': ChartSeriesConfig(label: 'Referral'),
    'email': ChartSeriesConfig(label: 'Email'),
  };

  @override
  Widget build(BuildContext context) {
    final data = <ChartRow>[
      for (final source in analyticsSources)
        {
          'source': source.source.toLowerCase(),
          'visitors': analyticsRound(period.visitors * source.share),
        },
    ];
    final total = data.fold<num>(
      0,
      (sum, row) => sum + ((row['visitors'] as num?) ?? 0),
    );
    return Card(
      seed: 'analytics-sources',
      children: [
        const CardHeader(
          children: [
            CardTitle(Text('Where they came from')),
            CardDescription(Text('Visitors by the door they used')),
          ],
        ),
        CardContent(
          child: ChartContainer(
            config: _config,
            height: Spacing.d256,
            children: [
              DonutChart(
                data: data,
                nameKey: 'source',
                valueKey: 'visitors',
                label: 'Visitors by source',
                showLabels: false,
                centerLabel: (_) => ChartCenterLabel(
                  value: analyticsNumber(total),
                  label: 'visitors',
                ),
              ),
              const ChartTooltip(),
              const ChartLegend(),
            ],
          ),
        ),
      ],
    );
  }
}
