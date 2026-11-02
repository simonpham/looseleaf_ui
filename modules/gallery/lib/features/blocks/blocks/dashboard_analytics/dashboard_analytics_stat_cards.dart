import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

typedef _Stat = ({
  String id,
  String label,
  String value,
  double delta,
  String unit,
  bool betterUp,
  List<num> data,
  SparkVariant variant,
});

/// The four key numbers, each with a sparkline and its change on the days
/// before.
class DashboardAnalyticsStatCards extends StatelessWidget {
  const DashboardAnalyticsStatCards({
    super.key,
    required this.period,
    required this.width,
  });

  final AnalyticsPeriod period;

  /// The block's width, standing in for upstream's viewport breakpoints.
  final double width;

  static const List<int> _sparkSlot = [0, 1, 4, 3];

  List<_Stat> _stats() {
    final p = period;
    return [
      (
        id: 'visitors',
        label: 'Visitors',
        value: analyticsNumber(p.visitors),
        delta: analyticsChange(p.visitors, p.previousVisitors),
        unit: '%',
        betterUp: true,
        data: [for (final row in p.rows) row.$2],
        variant: SparkVariant.line,
      ),
      (
        id: 'pageviews',
        label: 'Pageviews',
        value: analyticsNumber(p.pageviews),
        delta: analyticsChange(p.pageviews, p.previousPageviews),
        unit: '%',
        betterUp: true,
        data: [for (final row in p.rows) row.$3],
        variant: SparkVariant.area,
      ),
      (
        id: 'bounce',
        label: 'Bounce rate',
        value: '${p.bounce}%',
        delta: analyticsRound((p.bounce - p.previousBounce) * 10) / 10,
        unit: ' pts',
        betterUp: false,
        data: [for (final row in p.rows) row.$4 / 10],
        variant: SparkVariant.line,
      ),
      (
        id: 'session',
        label: 'Time on site',
        value: analyticsDuration(p.session),
        delta: analyticsChange(p.session, p.previousSession),
        unit: '%',
        betterUp: true,
        data: [for (final row in p.rows) row.$5],
        variant: SparkVariant.bar,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final columns = switch (width) {
      >= 1280 => 4,
      >= 640 => 2,
      _ => 1,
    };
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    final cards = [
      for (final (index, stat) in _stats().indexed)
        LayoutBuilder(
          builder: (context, constraints) {
            final good = switch (stat.betterUp) {
              true => stat.delta >= 0,
              false => stat.delta <= 0,
            };
            return Card(
              seed: 'analytics-stat-${stat.id}',
              gap: Spacing.d8,
              padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
              children: [
                CardHeader(
                  children: [
                    CardDescription(Text(stat.label)),
                    CardTitle(
                      Text(
                        stat.value,
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: switch (constraints.maxWidth >= 280) {
                            true => 30,
                            false => 24,
                          },
                          cssLineHeight: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CardAction(
                      child: Padding(
                        padding: const EdgeInsets.only(top: Spacing.d4),
                        child: Sparkline(
                          data: stat.data,
                          variant: stat.variant,
                          slot: _sparkSlot[index],
                          label: '${stat.label}, one point per day',
                        ),
                      ),
                    ),
                  ],
                ),
                DefaultTextStyle.merge(
                  style: muted,
                  child: CardFooter(
                    wrap: true,
                    spacing: Spacing.d6,
                    children: [
                      DashboardAnalyticsTrend(
                        text: analyticsSigned(stat.delta, stat.unit),
                        up: stat.delta >= 0,
                        good: good,
                        spoken: switch (good) {
                          true => ', better',
                          false => ', worse',
                        },
                      ),
                      Text('on the ${period.days} days before'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
    ];
    return Semantics(
      container: true,
      label: 'Key numbers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          for (var start = 0; start < cards.length; start += columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final card in cards.skip(start).take(columns))
                  Expanded(child: card),
              ],
            ),
        ],
      ),
    );
  }
}
