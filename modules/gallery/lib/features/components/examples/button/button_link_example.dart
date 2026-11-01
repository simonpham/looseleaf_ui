import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonLinkExample extends StatelessWidget {
  const ButtonLinkExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(onPressed: () {}, child: const Text('Open the notebook')),
      Button(
        variant: ButtonVariant.outline,
        onPressed: () {},
        child: const Text('Pricing'),
      ),
      Button(
        variant: ButtonVariant.link,
        onPressed: () {},
        child: const Text('Read the docs'),
      ),
      const Button(
        variant: ButtonVariant.secondary,
        disabled: true,
        child: Text('Coming soon'),
      ),
    ],
  );
}
