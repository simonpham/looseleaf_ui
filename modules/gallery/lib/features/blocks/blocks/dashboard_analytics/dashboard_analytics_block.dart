import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Traffic on one sheet: four sparkline numbers, visitors day by day,
/// sources, top pages and a checkout funnel, all re-worked by the date
/// range.
///
/// Mirrors upstream `src/blocks/dashboard-analytics/page.tsx`.
class DashboardAnalyticsBlock extends StatefulWidget {
  const DashboardAnalyticsBlock({super.key, this.onExportCsv});

  /// Gets the period's CSV; copies it to the clipboard when null.
  final ValueChanged<String>? onExportCsv;

  @override
  State<DashboardAnalyticsBlock> createState() =>
      _DashboardAnalyticsBlockState();
}

class _DashboardAnalyticsBlockState extends State<DashboardAnalyticsBlock> {
  String _rangeId = '30d';

  static const double _noteWidth = 192;
  static const double _noteHeight = 128;

  void _export(AnalyticsPeriod period) {
    final csv = [
      'date,visitors,pageviews,bounce_percent,average_session_seconds',
      for (final row in period.rows)
        '${row.$1},${row.$2},${row.$3},${row.$4 / 10},${row.$5}',
    ].join('\n');
    if (widget.onExportCsv case final export?) {
      export(csv);
      return;
    }
    unawaited(Clipboard.setData(ClipboardData(text: csv)));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => _sheet(context, constraints.maxWidth),
  );

  Widget _sheet(BuildContext context, double width) {
    final theme = LooseleafTheme.of(context);
    final range = analyticsRanges.firstWhere(
      (r) => r.id == _rangeId,
      orElse: () => analyticsRanges[1],
    );
    final period = AnalyticsPeriod(range.days);
    final small = width >= 640;
    final large = width >= 1024;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        PageHeader(
          children: [
            Text(
              'Marigold Paper Co.',
              style: theme.typography
                  .stamp(cssSize: 14, color: theme.colors.inkMuted)
                  .copyWith(letterSpacing: 0.35),
            ),
            const PageTitle(Text('Traffic'), seed: 'analytics-title'),
            PageDescription(
              Text(
                'How people found the studio in ${range.long}, and what they did once they got here.',
              ),
            ),
          ],
        ),
        Wrap(
          spacing: Spacing.d12,
          runSpacing: Spacing.d12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ToggleGroup<String>(
              value: {_rangeId},
              variant: ToggleVariant.outline,
              semanticLabel: 'Date range',
              onChanged: (next) {
                if (next.firstOrNull case final id?) {
                  setState(() => _rangeId = id);
                }
              },
              children: [
                for (final r in analyticsRanges)
                  ToggleGroupItem(value: r.id, child: Text(r.label)),
              ],
            ),
            Button(
              variant: ButtonVariant.outline,
              onPressed: () => _export(period),
              leading: const InkIcon('download'),
              child: const Text('Export CSV'),
            ),
          ],
        ),
      ],
    );
    final note = Semantics(
      container: true,
      label: 'Live now',
      child: StickyNote(
        fastener: FastenerKind.pin,
        seed: 'analytics-live',
        width: switch (small) {
          true => _noteWidth,
          false => double.infinity,
        },
        minHeight: _noteHeight,
        children: [
          const StickyNoteTitle(Text('Live now')),
          StickyNoteContent(
            Text(
              '${analyticsLive.readers} people are reading ${analyticsLive.page}.',
            ),
          ),
        ],
      ),
    );
    final traffic = DashboardAnalyticsTrafficChart(
      period: period,
      longName: range.long,
    );
    final sources = DashboardAnalyticsSourcesChart(period: period);
    final pages = DashboardAnalyticsTopPages(period: period, width: width);
    final funnel = DashboardAnalyticsFunnel(
      period: period,
      width: width,
      longName: range.long,
    );
    Widget pair(Widget first, int firstFlex, Widget second, int secondFlex) {
      if (large) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Expanded(flex: firstFlex, child: first),
            Expanded(flex: secondFlex, child: second),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [first, second],
      );
    }

    return PaperPage(
      width: PageWidth.full,
      tilt: false,
      rules: RuleName.none,
      seed: 'dashboard-analytics',
      children: [
        switch (small) {
          true => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Expanded(child: intro),
              note,
            ],
          ),
          false => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d16,
            children: [intro, note],
          ),
        },
        DashboardAnalyticsStatCards(period: period, width: width),
        pair(traffic, 2, sources, 1),
        pair(pages, 3, funnel, 2),
      ],
    );
  }
}
