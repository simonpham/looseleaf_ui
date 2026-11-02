import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_04/login_04.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What the login form hands to its `onSubmit`.
typedef Login04Values = ({String email, String password});

/// A card that opens into two columns from 672 px: the sign-in form, and
/// a kraft panel of polaroids. Three provider buttons sit in a row.
///
/// Mirrors upstream `src/blocks/login-04/components/login-04-form.tsx`.
class Login04Form extends StatefulWidget {
  const Login04Form({super.key, this.onSubmit});

  /// Signs in; a thrown error's message shows in the form.
  final Future<void> Function(Login04Values values)? onSubmit;

  @override
  State<Login04Form> createState() => _Login04FormState();
}

class _Login04FormState extends State<Login04Form> {
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

  static Future<void> _pretend(Login04Values values) =>
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

  static const double _splitFrom = 672;
  static const double _splitMinHeight = 608;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final split = width >= _splitFrom;
            final form = Padding(
              padding: EdgeInsets.all(switch (split) {
                true => Spacing.d32,
                false => Spacing.d24,
              }),
              child: _fields(theme),
            );
            return Card(
              seed: 'login-04',
              gap: 0,
              padding: EdgeInsets.zero,
              children: [
                CardContent(
                  padding: EdgeInsets.zero,
                  child: switch (split) {
                    false => form,
                    true => Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(end: width / 2),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: _splitMinHeight,
                            ),
                            child: Center(child: form),
                          ),
                        ),
                        PositionedDirectional(
                          top: 0,
                          bottom: 0,
                          end: 0,
                          width: width / 2,
                          child: const Login04Polaroids(),
                        ),
                      ],
                    ),
                  },
                ),
              ],
            );
          },
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
                    child: Login04Link('Terms of Service', plain: true),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Login04Link('Privacy Policy', plain: true),
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

  Widget _fields(LooseleafThemeData theme) => InkForm(
    controller: _form,
    semanticLabel: 'Sign in',
    child: FieldGroup(
      children: [
        Column(
          spacing: Spacing.d8,
          children: [
            Semantics(
              header: true,
              child: DefaultTextStyle.merge(
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 32,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
                child: const Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(text: 'Welcome '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Underline(
                          kind: UnderlineMarkKind.double,
                          tone: MarkPen.blue,
                          child: Text('back'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              'Sign in to your Looseleaf account.',
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.hand,
                color: theme.colors.inkMuted,
              ),
            ),
          ],
        ),
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
                    'Nothing was sent anywhere. Pass an onSubmit to Login04Form to sign in for real.',
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
              FieldLabel(focusNode: _emailFocus, child: const Text('Email')),
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
                  Login04Link(
                    'Forgot your password?',
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                    ),
                  ),
                ],
              ),
              Login04PasswordInput(
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
          ],
        ),
        const FieldSeparator(child: Text('Or continue with')),
        Row(
          spacing: Spacing.d16,
          children: [
            for (final (mark, name) in const [
              ('apple', 'Apple'),
              ('google', 'Google'),
              ('github', 'GitHub'),
            ])
              Expanded(
                child: Button(
                  variant: ButtonVariant.outline,
                  semanticLabel: 'Sign in with $name',
                  onPressed: () {},
                  child: Login04BrandMark(mark),
                ),
              ),
          ],
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
                  child: Login04Link('Make an account'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
