import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BadgeAsLinkExample extends StatelessWidget {
  const BadgeAsLinkExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Badge(onPressed: () {}, child: const Text('Docs')),
      Badge(
        variant: BadgeVariant.secondary,
        onPressed: () {},
        child: const Text('Releases'),
      ),
      Badge(
        variant: BadgeVariant.outline,
        onPressed: () {},
        child: const Text('#design'),
      ),
      Badge(
        variant: BadgeVariant.ghost,
        onPressed: () {},
        child: const Text('Ghost link'),
      ),
      Badge(
        variant: BadgeVariant.link,
        onPressed: () {},
        child: const Text('Read the changelog'),
      ),
    ],
  );
}
