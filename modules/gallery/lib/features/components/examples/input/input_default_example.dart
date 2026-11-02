import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputDefaultExample extends StatefulWidget {
  const InputDefaultExample({super.key});

  @override
  State<InputDefaultExample> createState() => _InputDefaultExampleState();
}

class _InputDefaultExampleState extends State<InputDefaultExample> {
  static const _maxWidth = 384.0;

  final _email = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Label(focusNode: _email, child: const Text('Email')),
        Input(
          focusNode: _email,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'you@example.com',
        ),
      ],
    ),
  );
}
