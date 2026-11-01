import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class KbdButtonExample extends StatelessWidget {
  const KbdButtonExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.sm,
        onPressed: () {},
        trailing: const Kbd(child: Text('⏎')),
        child: const Text('Accept'),
      ),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.sm,
        onPressed: () {},
        trailing: const Kbd(child: Text('Esc')),
        child: const Text('Cancel'),
      ),
    ],
  );
}
