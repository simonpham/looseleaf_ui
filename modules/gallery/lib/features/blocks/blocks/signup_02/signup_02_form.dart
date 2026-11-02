import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_02/signup_02.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What the sign-up form hands to `onSubmit`.
typedef Signup02Values = ({String name, String email, String password});

/// A bare sign-up form with a highlighted title: name, email, a password
/// typed twice and a GitHub button. Fields check themselves once you leave them.
///
/// Without [onSubmit] it pretends for 700 ms and shows a demo notice.
///
/// Mirrors upstream `src/blocks/signup-02/components/signup-02-form.tsx`.
class Signup02Form extends StatefulWidget {
  const Signup02Form({super.key, this.onSubmit});

  final Future<void> Function(Signup02Values values)? onSubmit;

  @override
  State<Signup02Form> createState() => _Signup02FormState();
}

class _Signup02FormState extends State<Signup02Form> {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _digit = RegExp(r'\d');

  final _form = FormController(
    initialValues: {'name': '', 'email': '', 'password': '', 'confirm': ''},
    mode: FormValidationMode.onTouched,
  );
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  String? _formError;
  bool _created = false;
  bool _submitting = false;

  @override
  void dispose() {
    _form.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _changePassword(String value) {
    _form.setValue('password', value);
    if (_text('confirm').isNotEmpty) _form.validate('confirm');
  }

  String _text(String name) => _form.value<String>(name) ?? '';

  String? _checkName(String? value) => switch ((value ?? '').trim().length) {
    < 2 => 'Tell us what to call you (at least 2 letters).',
    _ => null,
  };

  String? _checkEmail(String? value) => switch (_email.hasMatch(value ?? '')) {
    true => null,
    false => 'Enter a full address, like ada@notes.dev.',
  };

  String? _checkPassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use at least 8 characters.';
    if (!_digit.hasMatch(password)) return 'Add at least one number.';
    return null;
  }

  String? _checkConfirm(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'Type the password once more.';
    if (confirm != _text('password')) return 'Those two do not match yet.';
    return null;
  }

  static Future<void> _pretend(Signup02Values values) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  void _submit() => unawaited(_form.handleSubmit((_) => _create()));

  Future<void> _create() async {
    setState(() {
      _formError = null;
      _submitting = true;
    });
    final onSubmit = widget.onSubmit;
    try {
      await (onSubmit ?? _pretend)((
        name: _text('name'),
        email: _text('email'),
        password: _text('password'),
      ));
      if (!mounted) return;
      setState(() => _created = onSubmit == null);
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _formError = switch (error) {
          final String message when message.isNotEmpty => message,
          _ => 'Something went wrong on our side. Try again in a moment.',
        },
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _textField({
    required String name,
    required String label,
    required String placeholder,
    required FocusNode focusNode,
    required String? Function(String? value) validator,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    String? hint,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => Field(
      invalid: field.invalid,
      children: [
        FieldLabel(focusNode: focusNode, child: Text(label)),
        Input(
          focusNode: focusNode,
          placeholder: placeholder,
          invalid: field.invalid,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          onChanged: (value) => _form.setValue(name, value),
        ),
        if (hint case final hint?) FieldDescription(Text(hint)),
        if (field.error case final error?) FieldError(errors: [error]),
      ],
    ),
  );

  Widget _passwordField({
    required String name,
    required String label,
    required FocusNode focusNode,
    required String? Function(String? value) validator,
    required ValueChanged<String> onChanged,
    String toggleLabel = 'Show password',
    String? hint,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => Field(
      invalid: field.invalid,
      children: [
        FieldLabel(focusNode: focusNode, child: Text(label)),
        Signup02PasswordInput(
          focusNode: focusNode,
          invalid: field.invalid,
          toggleLabel: toggleLabel,
          onChanged: onChanged,
        ),
        if (hint case final hint?) FieldDescription(Text(hint)),
        if (field.error case final error?) FieldError(errors: [error]),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return InkForm(
      controller: _form,
      child: FieldGroup(
        children: [
          Column(
            spacing: Spacing.d4,
            children: [
              Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 32,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w700,
                    color: theme.colors.ink,
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Create your '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: Spacing.d4,
                            ),
                            child: Highlight(child: Text('account')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Fill in the form below and your seat is saved.',
                textAlign: TextAlign.center,
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
          if (_formError case final error?)
            Alert(
              variant: AlertTone.destructive,
              icon: const InkIcon('circle-alert'),
              children: [
                const AlertTitle(Text('We could not create your account')),
                AlertDescription(Text(error)),
              ],
            ),
          if (_created)
            const Alert(
              variant: AlertTone.success,
              icon: InkIcon('circle-check'),
              children: [
                AlertTitle(Text('Account created (this is a demo)')),
                AlertDescription(
                  Text(
                    'Nothing was sent anywhere. Pass an onSubmit to '
                    'Signup02Form to create accounts for real.',
                  ),
                ),
              ],
            ),
          _textField(
            name: 'name',
            label: 'Full name',
            placeholder: 'Ada Lovelace',
            focusNode: _nameFocus,
            validator: _checkName,
            autofillHints: const [AutofillHints.name],
          ),
          _textField(
            name: 'email',
            label: 'Email',
            placeholder: 'ada@notes.dev',
            focusNode: _emailFocus,
            validator: _checkEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            hint: 'We use this to reach you and never share it.',
          ),
          _passwordField(
            name: 'password',
            label: 'Password',
            focusNode: _passwordFocus,
            validator: _checkPassword,
            onChanged: _changePassword,
            hint: 'At least 8 characters and one number.',
          ),
          _passwordField(
            name: 'confirm',
            label: 'Confirm password',
            focusNode: _confirmFocus,
            validator: _checkConfirm,
            toggleLabel: 'Show password confirmation',
            onChanged: (value) => _form.setValue('confirm', value),
          ),
          Field(
            children: [
              Button(
                disabled: _submitting,
                onPressed: _submit,
                leading: switch (_submitting) {
                  true => const ExcludeSemantics(child: Spinner()),
                  false => null,
                },
                child: Text(switch (_submitting) {
                  true => 'Creating account',
                  false => 'Create account',
                }),
              ),
            ],
          ),
          const FieldSeparator(child: Text('Or continue with')),
          Field(
            children: [
              Button(
                variant: ButtonVariant.outline,
                onPressed: () {},
                leading: const Signup02BrandMark(Signup02Brand.github),
                child: const Text('Sign up with GitHub'),
              ),
              const FieldDescription(
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(text: 'Already have an account? '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Signup02Link('Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
