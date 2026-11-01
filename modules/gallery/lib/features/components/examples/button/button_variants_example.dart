import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonVariantsExample extends StatelessWidget {
  const ButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(onPressed: () {}, child: const Text('Save changes')),
      Button(
        variant: ButtonVariant.destructive,
        onPressed: () {},
        child: const Text('Delete'),
      ),
      Button(
        variant: ButtonVariant.outline,
        onPressed: () {},
        child: const Text('Outline'),
      ),
      Button(
        variant: ButtonVariant.secondary,
        onPressed: () {},
        child: const Text('Secondary'),
      ),
      Button(
        variant: ButtonVariant.ghost,
        onPressed: () {},
        child: const Text('Ghost'),
      ),
      Button(
        variant: ButtonVariant.link,
        onPressed: () {},
        child: const Text('Read more'),
      ),
    ],
  );
}
