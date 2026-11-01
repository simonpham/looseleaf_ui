import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BadgeSizesIconsTonesExample extends StatelessWidget {
  const BadgeSizesIconsTonesExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(size: BadgeSize.sm, child: Text('Small')),
          Badge(child: Text('Default')),
          Badge(size: BadgeSize.lg, child: Text('Large')),
        ],
      ),
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(
            variant: BadgeVariant.secondary,
            leading: InkIcon('badge-check'),
            child: Text('Verified'),
          ),
          Badge(
            variant: BadgeVariant.destructive,
            leading: InkIcon('triangle-alert'),
            child: Text('Overdue'),
          ),
          Badge(
            variant: BadgeVariant.outline,
            leading: InkIcon('bell'),
            child: Text('Following'),
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d12,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(tone: BadgeTone.hi, child: Text('hi')),
          Badge(tone: BadgeTone.tangerine, child: Text('tangerine')),
          Badge(tone: BadgeTone.lemon, child: Text('lemon')),
          Badge(tone: BadgeTone.grass, child: Text('grass')),
          Badge(tone: BadgeTone.teal, child: Text('teal')),
          Badge(tone: BadgeTone.sky, child: Text('sky')),
          Badge(tone: BadgeTone.bubblegum, child: Text('bubblegum')),
        ],
      ),
    ],
  );
}
