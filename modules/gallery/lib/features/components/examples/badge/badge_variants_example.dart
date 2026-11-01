import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BadgeVariantsExample extends StatelessWidget {
  const BadgeVariantsExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Badge(child: Text('Badge')),
      Badge(variant: BadgeVariant.secondary, child: Text('Secondary')),
      Badge(variant: BadgeVariant.destructive, child: Text('Destructive')),
      Badge(variant: BadgeVariant.outline, child: Text('Outline')),
      Badge(variant: BadgeVariant.ghost, child: Text('Ghost')),
      Badge(variant: BadgeVariant.link, child: Text('Link')),
    ],
  );
}
