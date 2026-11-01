import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonIconButtonsExample extends StatefulWidget {
  const ButtonIconButtonsExample({super.key});

  @override
  State<ButtonIconButtonsExample> createState() =>
      _ButtonIconButtonsExampleState();
}

class _ButtonIconButtonsExampleState extends State<ButtonIconButtonsExample> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(
        size: ButtonSize.iconXs,
        variant: ButtonVariant.outline,
        semanticLabel: 'Close',
        onPressed: () {},
        child: const InkIcon('x', size: Spacing.d12),
      ),
      Button(
        size: ButtonSize.iconSm,
        variant: ButtonVariant.secondary,
        semanticLabel: 'Notifications',
        onPressed: () {},
        child: const InkIcon('bell'),
      ),
      Button(
        size: ButtonSize.icon,
        semanticLabel: 'Add',
        onPressed: () {},
        child: const InkIcon('plus'),
      ),
      Button(
        size: ButtonSize.iconLg,
        variant: ButtonVariant.outline,
        semanticLabel: 'Settings',
        onPressed: () {},
        child: const InkIcon('settings', size: Spacing.d20),
      ),
      Button(
        size: ButtonSize.icon,
        variant: ButtonVariant.ghost,
        semanticLabel: 'Delete',
        onPressed: () {},
        child: const InkIcon('trash'),
      ),
      Button(
        size: ButtonSize.icon,
        variant: ButtonVariant.outline,
        semanticLabel: switch (_shown) {
          true => 'Hide password',
          false => 'Show password',
        },
        onPressed: () => setState(() => _shown = !_shown),
        child: InkIcon(switch (_shown) {
          true => 'eye-off',
          false => 'eye',
        }),
      ),
    ],
  );
}
