import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldErrorsExample extends StatefulWidget {
  const FieldErrorsExample({super.key});

  @override
  State<FieldErrorsExample> createState() => _FieldErrorsExampleState();
}

class _FieldErrorsExampleState extends State<FieldErrorsExample> {
  static const _maxWidth = Spacing.d384;
  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');
  static final _digit = RegExp(r'\d');

  final _email = TextEditingController(text: 'ada');
  final _password = TextEditingController(text: 'pencil');
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  var _shown = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  List<String> get _emailErrors => [
    if (_shown && !_emailPattern.hasMatch(_email.text))
      'Enter an address like ada@notes.dev.',
  ];

  List<String> get _passwordErrors => [
    if (_shown && _password.text.length < 8) 'Use at least 8 characters.',
    if (_shown && !_digit.hasMatch(_password.text)) 'Add a number.',
  ];

  void _submit() => setState(() => _shown = true);

  @override
  Widget build(BuildContext context) {
    final emailErrors = _emailErrors;
    final passwordErrors = _passwordErrors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: FieldGroup(
        children: [
          Field(
            invalid: emailErrors.isNotEmpty,
            children: [
              FieldLabel(focusNode: _emailFocus, child: const Text('Email')),
              Input(
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                invalid: emailErrors.isNotEmpty,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              if (emailErrors.isNotEmpty) FieldError(errors: emailErrors),
            ],
          ),
          Field(
            invalid: passwordErrors.isNotEmpty,
            children: [
              FieldLabel(
                focusNode: _passwordFocus,
                child: const Text('Password'),
              ),
              Input(
                controller: _password,
                focusNode: _passwordFocus,
                obscureText: true,
                invalid: passwordErrors.isNotEmpty,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const FieldDescription(Text('Eight characters and a number.')),
              if (passwordErrors.isNotEmpty) FieldError(errors: passwordErrors),
            ],
          ),
          const FieldSeparator(child: Text('then')),
          Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Button(onPressed: _submit, child: const Text('Create account')),
              Button(
                variant: ButtonVariant.outline,
                onPressed: () => setState(() => _shown = false),
                child: const Text('Hide errors'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
