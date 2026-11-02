import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Pages, week by week": one tally row per week, this week in marker.
class ProfilePageWeeklyTally extends StatelessWidget {
  const ProfilePageWeeklyTally({
    super.key,
    required this.weeks,
    required this.width,
  });

  final List<ProfilePageWeek> weeks;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;

  static const double _labelWidth = 128;
  static const double _countWidth = 48;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    final count = theme.typography
        .interface(color: theme.colors.ink)
        .copyWith(
          fontWeight: FontWeight.w700,
        );
    final best = weeks.fold(
      0,
      (most, week) => switch (week.pages > most) {
        true => week.pages,
        false => most,
      },
    );
    final inline = width >= 448;
    Widget row(int index, ProfilePageWeek week) {
      final now = index == weeks.length - 1;
      final label = Text(switch (now) {
        true => 'This week',
        false => week.label,
      }, style: small);
      final tally = Tally(
        count: week.pages,
        size: TallySize.sm,
        tone: switch (now) {
          true => MarkPen.marker,
          false => MarkPen.ink,
        },
        label: '${week.pages} pages, ${week.label}',
        seed: 'week-$index',
      );
      final number = SizedBox(
        width: _countWidth,
        child: Text(
          '${week.pages}',
          style: count,
          textAlign: TextAlign.end,
        ),
      );
      if (inline) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d36),
          child: Row(
            spacing: Spacing.d12,
            children: [
              SizedBox(width: _labelWidth, child: label),
              Expanded(child: tally),
              number,
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d4,
          children: [
            Row(
              spacing: Spacing.d12,
              children: [
                Expanded(child: label),
                number,
              ],
            ),
            tally,
          ],
        ),
      );
    }

    final rule = BorderSide(
      color: theme.colors.ruleBlue.withValues(alpha: 0.6),
    );
    return Paper(
      stock: StockName.slip,
      seed: 'weekly-tally',
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d24,
        vertical: Spacing.d20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Wrap(
            spacing: Spacing.d16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Pages, week by week',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 30,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.ink,
                  ),
                ),
              ),
              Text('Best week: $best pages', style: small),
            ],
          ),
          Semantics(
            label: 'Pages written each week',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, week) in weeks.indexed)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: switch (index) {
                        0 => null,
                        _ => Border(top: rule),
                      },
                    ),
                    child: row(index, week),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
