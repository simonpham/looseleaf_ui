import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "From hello to paid": shoppers at each checkout step, with the biggest
/// drop circled in red.
class DashboardAnalyticsFunnel extends StatelessWidget {
  const DashboardAnalyticsFunnel({
    super.key,
    required this.width,
    required this.period,
    required this.longName,
  });

  final AnalyticsPeriod period;

  /// The block's width, standing in for upstream's viewport breakpoints.
  final double width;
  final String longName;

  static ({String from, String to, double kept}) _biggestDrop() {
    var worst = (
      from: analyticsFunnel[0].step,
      to: analyticsFunnel[1].step,
      kept: 1.0,
    );
    for (var i = 1; i < analyticsFunnel.length; i++) {
      final kept = analyticsFunnel[i].share / analyticsFunnel[i - 1].share;
      if (kept < worst.kept) {
        worst = (
          from: analyticsFunnel[i - 1].step,
          to: analyticsFunnel[i].step,
          kept: kept,
        );
      }
    }
    return worst;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final data = <ChartRow>[
      for (final step in analyticsFunnel)
        {
          'step': step.step,
          'people': analyticsRound(period.visitors * step.share),
        },
    ];
    final drop = _biggestDrop();
    final last = analyticsFunnel.last;
    final large = width >= 1024;
    const bold = TextStyle(fontWeight: FontWeight.w700);
    return Card(
      seed: 'analytics-funnel',
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('From hello to paid')),
            CardDescription(
              Text('Everyone who visited in $longName, step by step'),
            ),
          ],
        ),
        CardContent(
          child: ChartContainer(
            config: {
              'people': ChartSeriesConfig(
                label: 'People',
                color: theme.colors.green,
              ),
            },
            height: switch (large) {
              true => Spacing.d256 + Spacing.d96,
              false => Spacing.d256,
            },
            children: [
              BarChart(
                data: data,
                xKey: 'step',
                horizontal: true,
                showValues: true,
                valueFormatter: analyticsNumber,
                label: 'Shoppers at each step of the checkout, $longName',
              ),
              const ChartTooltip(),
            ],
          ),
        ),
        CardFooter(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: theme.typography.interface(cssSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d4,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Most people slip away between ',
                          ),
                          TextSpan(
                            text: drop.from.toLowerCase(),
                            style: bold,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(text: drop.to.toLowerCase(), style: bold),
                          const TextSpan(text: ': only '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.d6,
                              ),
                              child: Circled(
                                tone: MarkPen.red,
                                child: Text(
                                  '${analyticsRound(drop.kept * 100)}%',
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' go on.'),
                        ],
                      ),
                    ),
                    Text(
                      '${analyticsRound(last.share * 1000) / 10}% of visitors end up paying.',
                      style: TextStyle(color: theme.colors.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
