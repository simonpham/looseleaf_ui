import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldInputExample extends StatefulWidget {
  const FieldInputExample({super.key});

  @override
  State<FieldInputExample> createState() => _FieldInputExampleState();
}

class _FieldInputExampleState extends State<FieldInputExample> {
  static const _maxWidth = Spacing.d448;

  final _username = FocusNode();
  final _password = FocusNode();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldSet(
      children: [
        FieldGroup(
          children: [
            Field(
              children: [
                FieldLabel(focusNode: _username, child: const Text('Username')),
                Input(focusNode: _username, placeholder: 'Max Leiter'),
                const FieldDescription(
                  Text('Choose a unique username for your account.'),
                ),
              ],
            ),
            Field(
              children: [
                FieldLabel(focusNode: _password, child: const Text('Password')),
                const FieldDescription(
                  Text('Must be at least 8 characters long.'),
                ),
                Input(
                  focusNode: _password,
                  obscureText: true,
                  placeholder: '••••••••',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
