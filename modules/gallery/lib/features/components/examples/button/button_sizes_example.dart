import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonSizesExample extends StatelessWidget {
  const ButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Button(
            size: ButtonSize.xs,
            onPressed: () {},
            child: const Text('Extra small'),
          ),
          Button(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Small'),
          ),
          Button(onPressed: () {}, child: const Text('Default')),
          Button(
            size: ButtonSize.lg,
            onPressed: () {},
            child: const Text('Large'),
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (size, variant) in const [
            (ButtonSize.iconXs, ButtonVariant.primary),
            (ButtonSize.iconSm, ButtonVariant.outline),
            (ButtonSize.icon, ButtonVariant.secondary),
            (ButtonSize.iconLg, ButtonVariant.ghost),
          ])
            Button(
              size: size,
              variant: variant,
              semanticLabel: 'Add',
              onPressed: () {},
              child: const Text('+'),
            ),
        ],
      ),
    ],
  );
}
