import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The stat slips: pages, notebooks, words a day and the writing streak.
class ProfilePageStats extends StatelessWidget {
  const ProfilePageStats({
    super.key,
    required this.profile,
    required this.width,
  });

  final ProfilePageProfile profile;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final roomy = width >= 576;
    final columns = switch (width >= 1024) {
      true => 4,
      false => 2,
    };
    final gap = switch (roomy) {
      true => Spacing.d20,
      false => Spacing.d12,
    };
    final small = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    final number = theme.typography.face(
      KevinSansFace.script,
      cssSize: switch (roomy) {
        true => 48,
        false => 36,
      },
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
      color: theme.colors.ink,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: switch (roomy) {
        true => Spacing.d20,
        false => Spacing.d16,
      },
      vertical: Spacing.d16,
    );
    Widget slip({
      required String seed,
      required String label,
      required String value,
      required Widget note,
      StockName stock = StockName.slip,
      RuleName? rules,
    }) => Paper(
      stock: stock,
      rules: rules,
      seed: seed,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          Text(label, style: small),
          Text(value, style: number),
          note,
        ],
      ),
    );
    final slips = [
      for (final (index, stat) in profile.stats.indexed)
        slip(
          seed: 'stat-${stat.id}',
          label: stat.label,
          value: stat.value,
          stock: switch (index) {
            1 => StockName.indexCard,
            _ => StockName.slip,
          },
          rules: switch (index) {
            1 => RuleName.none,
            _ => null,
          },
          note: Text(stat.note, style: small),
        ),
      slip(
        seed: 'stat-streak',
        label: 'Writing streak',
        value: '${profile.streakDays} days',
        note: Tally(
          count: profile.streakDays,
          size: TallySize.sm,
          tone: MarkPen.marker,
          label: '${profile.streakDays} days in a row',
          seed: 'streak',
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        for (var start = 0; start < slips.length; start += columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: [
                for (final slip in slips.skip(start).take(columns))
                  Expanded(child: slip),
              ],
            ),
          ),
      ],
    );
  }
}
