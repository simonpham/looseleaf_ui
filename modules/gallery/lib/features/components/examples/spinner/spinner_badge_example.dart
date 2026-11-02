import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerBadgeExample extends StatelessWidget {
  const SpinnerBadgeExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d12,
    children: [
      Badge(leading: Spinner(), child: Text('Syncing')),
      Badge(
        variant: BadgeVariant.secondary,
        leading: Spinner(),
        child: Text('Updating'),
      ),
      Badge(
        variant: BadgeVariant.outline,
        leading: Spinner(),
        child: Text('Processing'),
      ),
    ],
  );
}
