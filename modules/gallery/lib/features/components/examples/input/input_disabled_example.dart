import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputDisabledExample extends StatelessWidget {
  const InputDisabledExample({super.key});

  static const _maxWidth = 320.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Input(
      disabled: true,
      keyboardType: TextInputType.emailAddress,
      placeholder: 'Email',
      semanticLabel: 'Email',
    ),
  );
}
