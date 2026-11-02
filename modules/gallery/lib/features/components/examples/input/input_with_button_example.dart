import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputWithButtonExample extends StatelessWidget {
  const InputWithButtonExample({super.key});

  static const _maxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Row(
      spacing: Spacing.d8,
      children: [
        const Expanded(
          child: Input(
            keyboardType: TextInputType.emailAddress,
            placeholder: 'Email',
            semanticLabel: 'Email',
          ),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () {},
          child: const Text('Subscribe'),
        ),
      ],
    ),
  );
}
