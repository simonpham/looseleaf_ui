import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_05/login_05.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Passwordless sign-in: Stubby waving over "Welcome to Looseleaf", one
/// email field that sends a sign-in link, then Apple and Google.
///
/// Mirrors upstream `src/blocks/login-05/components/login-05-form.tsx`.
class Login05Form extends StatefulWidget {
  const Login05Form({super.key, this.onSubmit});

  /// Sends the link to the email; a thrown error's message shows in the
  /// form.
  final Future<void> Function(String email)? onSubmit;

  @override
  State<Login05Form> createState() => _Login05FormState();
}

class _Login05FormState extends State<Login05Form> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const double _twoColumnsFrom = 384;

  final _form = FormController(initialValues: {'email': ''});
  final _email = TextEditingController();
  final _emailFocus = FocusNode();
  final _sentFocus = FocusNode();
  bool _touched = false;
  String? _formError;
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_blurEmail);
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_blurEmail)
      ..dispose();
    _sentFocus.dispose();
    _email.dispose();
    _form.dispose();
    super.dispose();
  }

  void _blurEmail() {
    if (_emailFocus.hasFocus || _sentTo != null) return;
    _touched = true;
    _form.validate('email');
  }

  void _change(String value) {
    _form.setValue('email', value);
    if (_touched) _form.validate('email');
  }

  static String? _validateEmail(String? value) =>
      switch (_emailPattern.hasMatch(value ?? '')) {
        true => null,
        false => 'Enter a full address, like ada@notes.dev.',
      };

  static Future<void> _pretend(String email) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  Future<void> _send(Map<String, Object?> values) async {
    setState(() => _formError = null);
    final email = '${values['email'] ?? ''}';
    try {
      await (widget.onSubmit ?? _pretend)(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _sentFocus.requestFocus(),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final message = '$error';
      setState(
        () => _formError = switch (message.isEmpty) {
          true => 'We could not send that link. Try again in a moment.',
          false => message,
        },
      );
    }
  }

  void _submit() => unawaited(_form.handleSubmit(_send));

  void _useDifferentEmail(String sentTo) {
    _touched = false;
    _form.reset({'email': sentTo});
    _email.text = sentTo;
    setState(() => _sentTo = null);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _emailFocus.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final sentTo = _sentTo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        InkForm(
          controller: _form,
          semanticLabel: 'Sign in',
          child: FieldGroup(
            children: [
              Column(
                spacing: Spacing.d8,
                children: [
                  Mascot(
                    pose: switch (sentTo) {
                      null => 'wave',
                      _ => 'celebrate',
                    },
                    size: 88,
                  ),
                  Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 36,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                      child: const Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(text: 'Welcome to '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: Spacing.d4,
                                ),
                                child: Highlight(child: Text('Looseleaf')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const FieldDescription(
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(text: 'New here? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Login05Link('Make an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_formError case final message?)
                Alert(
                  variant: AlertTone.destructive,
                  icon: const InkIcon('circle-alert'),
                  children: [
                    const AlertTitle(Text('That did not go through')),
                    AlertDescription(Text(message)),
                  ],
                ),
              ...switch (sentTo) {
                final email? => [
                  Focus(
                    focusNode: _sentFocus,
                    child: Semantics(
                      liveRegion: true,
                      child: Alert(
                        variant: AlertTone.success,
                        icon: const InkIcon('mail-check'),
                        children: [
                          const AlertTitle(Text('Your link is on its way')),
                          AlertDescription(
                            Text(
                              '$email will have it in a minute. Open it on this device to sign in.${switch (widget.onSubmit) {
                                null => ' (This is a demo: nothing was sent.)',
                                _ => '',
                              }}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Field(
                    children: [
                      Button(
                        variant: ButtonVariant.outline,
                        onPressed: () => _useDifferentEmail(email),
                        child: const Text('Use a different email'),
                      ),
                    ],
                  ),
                ],
                null => [
                  InkFormField<String>(
                    name: 'email',
                    validator: _validateEmail,
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        FieldLabel(
                          focusNode: _emailFocus,
                          child: const Text('Email'),
                        ),
                        Input(
                          controller: _email,
                          focusNode: _emailFocus,
                          placeholder: 'ada@notes.dev',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          invalid: field.invalid,
                          semanticLabel: 'Email',
                          onChanged: _change,
                          onSubmitted: (_) => _submit(),
                        ),
                        FieldError(errors: [field.error]),
                      ],
                    ),
                  ),
                  Field(
                    children: [
                      ListenableBuilder(
                        listenable: _form,
                        builder: (context, _) => Button(
                          disabled: _form.isSubmitting,
                          onPressed: _submit,
                          leading: switch (_form.isSubmitting) {
                            true => const ExcludeSemantics(child: Spinner()),
                            false => null,
                          },
                          child: Text(switch (_form.isSubmitting) {
                            true => 'Sending',
                            false => 'Email me a sign-in link',
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              },
              const FieldSeparator(child: Text('Or continue with')),
              LayoutBuilder(
                builder: (context, constraints) {
                  final apple = Button(
                    variant: ButtonVariant.outline,
                    semanticLabel: 'Continue with Apple',
                    onPressed: () {},
                    leading: const Login05BrandMark('apple'),
                    child: const Text('Apple'),
                  );
                  final google = Button(
                    variant: ButtonVariant.outline,
                    semanticLabel: 'Continue with Google',
                    onPressed: () {},
                    leading: const Login05BrandMark('google'),
                    child: const Text('Google'),
                  );
                  return switch (constraints.maxWidth >= _twoColumnsFrom) {
                    true => Row(
                      spacing: Spacing.d16,
                      children: [
                        Expanded(child: apple),
                        Expanded(child: google),
                      ],
                    ),
                    false => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d16,
                      children: [apple, google],
                    ),
                  };
                },
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.d24),
          child: FieldDescription(
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(text: 'By continuing you agree to our '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Login05Link('Terms of Service'),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Login05Link('Privacy Policy'),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
