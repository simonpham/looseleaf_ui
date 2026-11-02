import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_05/signup_05.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What the sign-up form hands to `onSubmit`.
typedef Signup05Values = ({String email});

/// A one-field sign-up: Stubby thinking over "Pull up a chair", an email
/// for a magic link, and Apple and Google buttons. Once sent, Stubby
/// celebrates and the form becomes a "check your inbox" note.
///
/// Without [onSubmit] it pretends for 700 ms and says nothing was sent.
///
/// Mirrors upstream `src/blocks/signup-05/components/signup-05-form.tsx`.
class Signup05Form extends StatefulWidget {
  const Signup05Form({super.key, this.onSubmit});

  final Future<void> Function(Signup05Values values)? onSubmit;

  @override
  State<Signup05Form> createState() => _Signup05FormState();
}

class _Signup05FormState extends State<Signup05Form> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const double _twoButtonsFrom = 384;

  final _form = FormController(initialValues: {'email': ''});
  final _email = TextEditingController();
  final _emailFocus = FocusNode();
  bool _touched = false;
  String? _formError;
  String? _sentTo;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_checkOnLeave);
  }

  @override
  void dispose() {
    _form.dispose();
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _checkOnLeave() {
    if (_emailFocus.hasFocus) return;
    _touched = true;
    _form.validate('email');
  }

  void _change(String value) {
    _form.setValue('email', value);
    if (_touched) _form.validate('email');
  }

  String? _checkEmail(String? value) =>
      switch (_emailPattern.hasMatch(value ?? '')) {
        true => null,
        false => 'Enter a full address, like ada@notes.dev.',
      };

  static Future<void> _pretend(Signup05Values values) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  void _submit() => unawaited(_form.handleSubmit((_) => _send()));

  Future<void> _send() async {
    final email = _form.value<String>('email') ?? '';
    setState(() {
      _formError = null;
      _submitting = true;
    });
    try {
      await (widget.onSubmit ?? _pretend)((email: email));
      if (!mounted) return;
      setState(() => _sentTo = email);
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _formError = switch (error) {
          final String message when message.isNotEmpty => message,
          _ => 'We could not send that link. Try again in a moment.',
        },
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _useDifferentEmail() {
    final email = _sentTo ?? '';
    _form.reset({'email': email});
    _email.text = email;
    _touched = false;
    setState(() => _sentTo = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _emailFocus.requestFocus();
    });
  }

  List<Widget> _sent(String email) => [
    Alert(
      variant: AlertTone.success,
      icon: const InkIcon('mail-check'),
      children: [
        const AlertTitle(Text('Check your inbox')),
        AlertDescription(
          Text(
            'A link is on its way to $email. Open it on this device to '
            'finish.${switch (widget.onSubmit) {
              null => ' (This is a demo: nothing was sent.)',
              _ => '',
            }}',
          ),
        ),
      ],
    ),
    Field(
      children: [
        Button(
          variant: ButtonVariant.outline,
          onPressed: _useDifferentEmail,
          child: const Text('Use a different email'),
        ),
      ],
    ),
  ];

  List<Widget> _entry() => [
    InkFormField<String>(
      name: 'email',
      validator: _checkEmail,
      builder: (context, field) => Field(
        invalid: field.invalid,
        children: [
          FieldLabel(focusNode: _emailFocus, child: const Text('Email')),
          Input(
            controller: _email,
            focusNode: _emailFocus,
            placeholder: 'ada@notes.dev',
            invalid: field.invalid,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: _change,
          ),
          if (field.error case final error?) FieldError(errors: [error]),
        ],
      ),
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
            true => 'Sending',
            false => 'Email me a link to start',
          }),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final providers = [
      for (final (brand, name) in const [
        (Signup05Brand.apple, 'Apple'),
        (Signup05Brand.google, 'Google'),
      ])
        Button(
          variant: ButtonVariant.outline,
          semanticLabel: 'Continue with $name',
          onPressed: () {},
          leading: Signup05BrandMark(brand),
          child: Text(name),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        InkForm(
          controller: _form,
          child: FieldGroup(
            children: [
              Column(
                spacing: Spacing.d8,
                children: [
                  Mascot(
                    pose: switch (_sentTo) {
                      null => 'think',
                      _ => 'celebrate',
                    },
                    size: 88,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.d12,
                    ),
                    child: Semantics(
                      header: true,
                      child: DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 36,
                          cssLineHeight: 1,
                          fontWeight: FontWeight.w700,
                          color: theme.colors.ink,
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Pull up a '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.d8,
                                  ),
                                  child: Circled(
                                    tone: MarkPen.marker,
                                    child: Text('chair'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                            child: Signup05Link('Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_formError case final error?)
                Alert(
                  variant: AlertTone.destructive,
                  icon: const InkIcon('circle-alert'),
                  children: [
                    const AlertTitle(Text('That did not go through')),
                    AlertDescription(Text(error)),
                  ],
                ),
              ...switch (_sentTo) {
                final email? => _sent(email),
                null => _entry(),
              },
              const FieldSeparator(child: Text('Or continue with')),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < _twoButtonsFrom) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d16,
                      children: providers,
                    );
                  }
                  return Row(
                    spacing: Spacing.d16,
                    children: [
                      for (final button in providers) Expanded(child: button),
                    ],
                  );
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
                    child: Signup05Link('Terms of Service'),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Signup05Link('Privacy Policy'),
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
