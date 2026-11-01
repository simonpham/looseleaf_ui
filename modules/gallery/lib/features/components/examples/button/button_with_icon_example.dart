import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonWithIconExample extends StatelessWidget {
  const ButtonWithIconExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(
        onPressed: () {},
        leading: const InkIcon('plus'),
        child: const Text('New note'),
      ),
      Button(
        variant: ButtonVariant.outline,
        onPressed: () {},
        leading: const InkIcon('search'),
        child: const Text('Search'),
      ),
      Button(
        variant: ButtonVariant.secondary,
        onPressed: () {},
        trailing: const InkIcon('arrow-right'),
        child: const Text('Next'),
      ),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.lg,
        onPressed: () {},
        leading: const InkIcon('trash'),
        child: const Text('Discard'),
      ),
      Button(
        variant: ButtonVariant.ghost,
        size: ButtonSize.sm,
        onPressed: () {},
        leading: const InkIcon('copy'),
        child: const Text('Copy link'),
      ),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.xs,
        onPressed: () {},
        leading: const InkIcon('pencil', size: Spacing.d12),
        child: const Text('Edit'),
      ),
      Button(
        variant: ButtonVariant.link,
        onPressed: () {},
        trailing: const InkIcon('arrow-up-right'),
        child: const Text('Read more'),
      ),
    ],
  );
}
