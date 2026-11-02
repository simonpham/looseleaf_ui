import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_01/login_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What the login form hands to its `onSubmit`.
typedef Login01Values = ({String email, String password, bool remember});

/// The sign-in card: email, password with a show button, "remember me",
/// Google, and a demo success note when no `onSubmit` is given. Stubby
/// peeks over the top edge.
///
/// Mirrors upstream `src/blocks/login-01/components/login-01-form.tsx`.
class Login01Form extends StatefulWidget {
  const Login01Form({super.key, this.onSubmit});

  /// Signs in; a thrown error's message shows in the form.
  final Future<void> Function(Login01Values values)? onSubmit;

  @override
  State<Login01Form> createState() => _Login01FormState();
}

class _Login01FormState extends State<Login01Form> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = FormController(
    initialValues: {'email': '', 'password': '', 'remember': true},
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

  static Future<void> _pretend(Login01Values values) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  Future<void> _signIn(Map<String, Object?> values) async {
    setState(() => _formError = null);
    final submit = widget.onSubmit ?? _pretend;
    try {
      await submit((
        email: '${values['email'] ?? ''}',
        password: '${values['password'] ?? ''}',
        remember: values['remember'] == true,
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const PositionedDirectional(
          end: Spacing.d36,
          top: Spacing.d16,
          child: IgnorePointer(
            child: FractionalTranslation(
              translation: Offset(0, -1),
              child: Mascot(pose: 'peek', size: 88),
            ),
          ),
        ),
        Card(
          tilt: false,
          tape: PaperTape.corner,
          tapeKind: TapeKind.washiDots,
          seed: 'login-01',
          children: [
            CardHeader(
              children: [
                CardTitle(
                  DefaultTextStyle.merge(
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 32,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w600,
                    ),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Welcome '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Underline(
                              kind: UnderlineMarkKind.wavy,
                              tone: MarkPen.marker,
                              child: Text('back'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const CardDescription(
                  Text('Sign in to pick up where you left off.'),
                ),
              ],
            ),
            CardContent(
              child: InkForm(
                controller: _form,
                semanticLabel: 'Sign in',
                child: FieldGroup(
                  children: [
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
                                'Nothing was sent anywhere. Pass an onSubmit to Login01Form to sign in for real.',
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
                              Login01Link(
                                'Forgot your password?',
                                style: theme.typography.face(
                                  KevinSansFace.hand,
                                  cssSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Login01PasswordInput(
                            focusNode: _passwordFocus,
                            invalid: field.invalid,
                            onChanged: (value) => _change('password', value),
                            onSubmitted: (_) => _submit(),
                          ),
                          FieldError(errors: [field.error]),
                        ],
                      ),
                    ),
                    InkFormField<bool>(
                      name: 'remember',
                      builder: (context, field) => Field(
                        orientation: FieldOrientation.horizontal,
                        children: [
                          Checkbox(
                            value: field.value ?? false,
                            onChanged: field.onChanged,
                            semanticLabel: 'Remember me on this desk',
                          ),
                          FieldLabel(
                            onPressed: () =>
                                field.onChanged(!(field.value ?? false)),
                            child: Text(
                              'Remember me on this desk',
                              style: theme.typography.face(
                                KevinSansFace.hand,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
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
                        Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          leading: const Login01BrandMark('google'),
                          child: const Text('Sign in with Google'),
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
                                  child: Login01Link('Make an account'),
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
      ],
    );
  }
}
