import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Top pages": views per page with visitors, time and bounce on wider
/// screens, and the trend since the period before.
class DashboardAnalyticsTopPages extends StatelessWidget {
  const DashboardAnalyticsTopPages({
    super.key,
    required this.period,
    required this.width,
  });

  final AnalyticsPeriod period;

  static const double _pageWidthNarrow = 128;
  static const double _pageWidth = 224;

  /// The block's width, standing in for upstream's viewport breakpoints.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final medium = width >= 768;
    final small = width >= 640;
    Widget end(Widget child) =>
        Align(alignment: AlignmentDirectional.centerEnd, child: child);
    return Card(
      seed: 'analytics-pages',
      children: [
        const CardHeader(
          children: [
            CardTitle(Text('Top pages')),
            CardDescription(
              Text(
                'What people read the most, and whether they liked it enough to stay',
              ),
            ),
          ],
        ),
        CardContent(
          child: InkTable(
            columnWidths: {
              0: MinColumnWidth(
                FixedColumnWidth(switch (small) {
                  true => _pageWidth,
                  false => _pageWidthNarrow,
                }),
                const IntrinsicColumnWidth(flex: 1),
              ),
            },
            header: TableHeader(
              rows: [
                InkTableRow(
                  cells: [
                    const TableHead(child: Text('Page')),
                    TableHead(child: end(const Text('Views'))),
                    if (medium) TableHead(child: end(const Text('Visitors'))),
                    if (medium) TableHead(child: end(const Text('Time'))),
                    if (small) TableHead(child: end(const Text('Bounce'))),
                    TableHead(child: end(const Text('Trend'))),
                  ],
                ),
              ],
            ),
            body: TableBody(
              rows: [
                for (final page in analyticsTopPages)
                  _row(theme, page, medium: medium, small: small, end: end),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InkTableRow _row(
    LooseleafThemeData theme,
    AnalyticsPage page, {
    required bool medium,
    required bool small,
    required Widget Function(Widget) end,
  }) {
    final views = analyticsRound(period.pageviews * page.share);
    final up = page.trend >= 0;
    return InkTableRow(
      cells: [
        InkTableCell(
          wrap: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                page.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.mono(
                  cssSize: 12,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        InkTableCell(child: end(Text(analyticsNumber(views)))),
        if (medium)
          InkTableCell(child: end(Text(analyticsNumber(views / 1.34)))),
        if (medium)
          InkTableCell(child: end(Text(analyticsDuration(page.time)))),
        if (small) InkTableCell(child: end(Text('${_trim(page.bounce)}%'))),
        InkTableCell(
          child: end(
            DashboardAnalyticsTrend(
              text: analyticsSigned(page.trend),
              up: up,
              good: up,
              spoken: switch (up) {
                true => ', up',
                false => ', down',
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _trim(double value) => switch (value == value.roundToDouble()) {
    true => '${value.round()}',
    false => '$value',
  };
}
