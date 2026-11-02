import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_03/login_03.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What the login form hands to its `onSubmit`.
typedef Login03Values = ({String email, String password});

/// The sign-in card: Apple and Google first, then email and password under
/// an "or continue with" rule, with the terms below the card.
///
/// Mirrors upstream `src/blocks/login-03/components/login-03-form.tsx`.
class Login03Form extends StatefulWidget {
  const Login03Form({super.key, this.onSubmit});

  /// Signs in; a thrown error's message shows in the form.
  final Future<void> Function(Login03Values values)? onSubmit;

  @override
  State<Login03Form> createState() => _Login03FormState();
}

class _Login03FormState extends State<Login03Form> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = FormController(
    initialValues: {'email': '', 'password': ''},
  );
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _touched = <String>{};
  String? _formError;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_blurEmail);
    _passwordFocus.addListener(_blurPassword);
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_blurEmail)
      ..dispose();
    _passwordFocus
      ..removeListener(_blurPassword)
      ..dispose();
    _form.dispose();
    super.dispose();
  }

  void _blurEmail() => _blur('email', _emailFocus);

  void _blurPassword() => _blur('password', _passwordFocus);

  void _blur(String name, FocusNode node) {
    if (node.hasFocus) return;
    _touched.add(name);
    _form.validate(name);
  }

  void _change(String name, String value) {
    _form.setValue(name, value);
    if (_touched.contains(name)) _form.validate(name);
  }

  static String? _validateEmail(String? value) =>
      switch (_emailPattern.hasMatch(value ?? '')) {
        true => null,
        false => 'Enter a full address, like ada@notes.dev.',
      };

  static String? _validatePassword(String? value) => switch (value ?? '') {
    '' => 'Enter your password.',
    _ => null,
  };

  static Future<void> _pretend(Login03Values values) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  Future<void> _signIn(Map<String, Object?> values) async {
    setState(() => _formError = null);
    final submit = widget.onSubmit ?? _pretend;
    try {
      await submit((
        email: '${values['email'] ?? ''}',
        password: '${values['password'] ?? ''}',
      ));
      if (!mounted || widget.onSubmit != null) return;
      setState(() => _signedIn = true);
    } on Object catch (error) {
      if (!mounted) return;
      final message = '$error';
      setState(
        () => _formError = switch (message.isEmpty) {
          true => 'Something went wrong on our side. Try again in a moment.',
          false => message,
        },
      );
    }
  }

  void _submit() => unawaited(_form.handleSubmit(_signIn));

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        Card(
          seed: 'login-03',
          children: [
            CardHeader(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CardTitle(
                    Text.rich(
                      textAlign: TextAlign.center,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 32,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w600,
                      ),
                      const TextSpan(
                        children: [
                          TextSpan(text: 'Welcome '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: Spacing.d4,
                              ),
                              child: Highlight(child: Text('back')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: CardDescription(
                    Text(
                      'Sign in with Apple or Google, or with your email.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            CardContent(
              child: InkForm(
                controller: _form,
                semanticLabel: 'Sign in',
                child: FieldGroup(
                  children: [
                    Field(
                      children: [
                        Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          leading: const Login03BrandMark('apple'),
                          child: const Text('Sign in with Apple'),
                        ),
                        Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          leading: const Login03BrandMark('google'),
                          child: const Text('Sign in with Google'),
                        ),
                      ],
                    ),
                    const FieldSeparator(child: Text('Or continue with')),
                    if (_formError case final message?)
                      Alert(
                        variant: AlertTone.destructive,
                        icon: const InkIcon('circle-alert'),
                        children: [
                          const AlertTitle(Text('We could not sign you in')),
                          AlertDescription(Text(message)),
                        ],
                      ),
                    if (_signedIn)
                      Semantics(
                        liveRegion: true,
                        child: const Alert(
                          variant: AlertTone.success,
                          icon: InkIcon('circle-check'),
                          children: [
                            AlertTitle(Text('You are in (this is a demo)')),
                            AlertDescription(
                              Text(
                                'Nothing was sent anywhere. Pass an onSubmit to Login03Form to sign in for real.',
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            focusNode: _emailFocus,
                            placeholder: 'ada@notes.dev',
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            invalid: field.invalid,
                            semanticLabel: 'Email',
                            onChanged: (value) => _change('email', value),
                          ),
                          FieldError(errors: [field.error]),
                        ],
                      ),
                    ),
                    InkFormField<String>(
                      name: 'password',
                      validator: _validatePassword,
                      builder: (context, field) => Field(
                        invalid: field.invalid,
                        children: [
                          Row(
                            spacing: Spacing.d12,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: FieldLabel(
                                    focusNode: _passwordFocus,
                                    child: const Text('Password'),
                                  ),
                                ),
                              ),
                              Login03Link(
                                'Forgot your password?',
                                style: theme.typography.face(
                                  KevinSansFace.hand,
                                  cssSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Login03PasswordInput(
                            focusNode: _passwordFocus,
                            invalid: field.invalid,
                            onChanged: (value) => _change('password', value),
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
                              true => 'Signing in',
                              false => 'Sign in',
                            }),
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
                                  child: Login03Link('Make an account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                    child: Login03Link('Terms of Service', plain: true),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Login03Link('Privacy Policy', plain: true),
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
