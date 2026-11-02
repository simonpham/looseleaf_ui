import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputWithLabelExample extends StatefulWidget {
  const InputWithLabelExample({super.key});

  @override
  State<InputWithLabelExample> createState() => _InputWithLabelExampleState();
}

class _InputWithLabelExampleState extends State<InputWithLabelExample> {
  static const _maxWidth = Spacing.d384;

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
      spacing: Spacing.d12,
      children: [
        Label(focusNode: _email, child: const Text('Email')),
        Input(
          focusNode: _email,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'Email',
        ),
      ],
    ),
  );
}
