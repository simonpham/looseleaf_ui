import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputSignupFormExample extends StatefulWidget {
  const InputSignupFormExample({super.key});

  @override
  State<InputSignupFormExample> createState() => _InputSignupFormExampleState();
}

class _InputSignupFormExampleState extends State<InputSignupFormExample> {
  static const _maxWidth = Spacing.d384;
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  String _email = '';
  bool _touched = false;
  bool _terms = false;
  bool _done = false;

  bool get _invalid => _touched && !_emailPattern.hasMatch(_email);

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocus);
  }

  void _onEmailFocus() {
    if (_emailFocus.hasFocus) return;
    setState(() => _touched = true);
  }

  void _submit() {
    setState(() {
      _touched = true;
      if (!_invalid && _email.isNotEmpty) _done = true;
    });
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onEmailFocus);
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Label(
                focusNode: _nameFocus,
                required: true,
                child: const Text('Your name'),
              ),
              Input(
                focusNode: _nameFocus,
                autofillHints: const [AutofillHints.name],
                placeholder: 'Ada Lovelace',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Label(
                focusNode: _emailFocus,
                required: true,
                child: const Text('Email'),
              ),
              Input(
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                invalid: _invalid,
                onChanged: (value) => setState(() => _email = value),
                placeholder: 'you@example.com',
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Spacing.d20),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    switch (_invalid) {
                      true => 'That does not look like an email address.',
                      false => '',
                    },
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Checkbox(
            value: _terms,
            onChanged: (value) => setState(() => _terms = value),
            label: const Text('I have read the small print'),
          ),
          Button(
            onPressed: _submit,
            child: Text(switch (_done) {
              true => 'Signed up, thanks',
              false => 'Sign up',
            }),
          ),
        ],
      ),
    );
  }
}
