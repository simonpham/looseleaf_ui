import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BadgeCountsAndTallyExample extends StatelessWidget {
  const BadgeCountsAndTallyExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d12,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(count: 3),
          Badge(count: 8, variant: BadgeVariant.secondary),
          Badge(count: 42, variant: BadgeVariant.outline),
          Badge(count: 128, variant: BadgeVariant.destructive),
          Badge(count: 1200, max: 999, variant: BadgeVariant.outline),
        ],
      ),
      Wrap(
        spacing: Spacing.d12,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(tally: true, count: 1, variant: BadgeVariant.outline),
          Badge(tally: true, count: 3, variant: BadgeVariant.outline),
          Badge(tally: true, count: 5, variant: BadgeVariant.outline),
          Badge(tally: true, count: 7, variant: BadgeVariant.secondary),
          Badge(tally: true, count: 12),
          Badge(tally: true, count: 9, variant: BadgeVariant.destructive),
        ],
      ),
    ],
  );
}
