import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputWithTextExample extends StatefulWidget {
  const InputWithTextExample({super.key});

  @override
  State<InputWithTextExample> createState() => _InputWithTextExampleState();
}

class _InputWithTextExampleState extends State<InputWithTextExample> {
  static const _maxWidth = Spacing.d384;

  final _email = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
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
          Text(
            'Enter your email address.',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
