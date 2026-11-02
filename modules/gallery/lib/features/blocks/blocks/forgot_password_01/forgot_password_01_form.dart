import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/forgot_password_01/forgot_password_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Asks for an email and sends a reset link; then shows where it went and
/// lets you send it again.
///
/// Mirrors upstream
/// `src/blocks/forgot-password-01/components/forgot-password-01-form.tsx`.
class ForgotPassword01Form extends StatefulWidget {
  const ForgotPassword01Form({super.key, this.onSubmit});

  /// Sends the link; a thrown error's message shows in the card.
  final Future<void> Function(String email)? onSubmit;

  @override
  State<ForgotPassword01Form> createState() => _ForgotPassword01FormState();
}

class _ForgotPassword01FormState extends State<ForgotPassword01Form> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = FormController(
    initialValues: {'email': ''},
    mode: FormValidationMode.onTouched,
  );
  final _emailFocus = FocusNode();
  final _titleFocus = FocusNode();
  String? _formError;
  String? _sentTo;
  bool _again = false;
  bool _resending = false;

  @override
  void dispose() {
    _emailFocus.dispose();
    _titleFocus.dispose();
    _form.dispose();
    super.dispose();
  }

  static String? _validateEmail(String? value) =>
      switch (_emailPattern.hasMatch(value ?? '')) {
        true => null,
        false => 'Enter a full address, like ada@notes.dev.',
      };

  static Future<void> _pretend(String email) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  Future<bool> _send(String email) async {
    setState(() => _formError = null);
    try {
      await (widget.onSubmit ?? _pretend)(email);
      if (!mounted) return false;
      final first = _sentTo == null;
      setState(() => _sentTo = email);
      if (first) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _titleFocus.requestFocus(),
        );
      }
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final message = '$error';
      setState(
        () => _formError = switch (message.isEmpty) {
          true => 'We could not send that link. Try again in a moment.',
          false => message,
        },
      );
      return false;
    }
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) => _send('${values['email'] ?? ''}')),
  );

  Future<void> _sendAgain(String email) async {
    if (_resending) return;
    setState(() {
      _resending = true;
      _again = false;
    });
    final sent = await _send(email);
    if (!mounted) return;
    setState(() {
      _again = sent;
      _resending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sentTo case final sentTo?) {
      return ForgotPassword01Sent(
        sentTo: sentTo,
        titleFocus: _titleFocus,
        demo: widget.onSubmit == null,
        formError: _formError,
        resending: _resending,
        sentAgain: _again,
        onSendAgain: () => unawaited(_sendAgain(sentTo)),
      );
    }
    final theme = LooseleafTheme.of(context);
    return Card(
      tape: PaperTape.corner,
      seed: 'forgot-password-01',
      children: [
        CardHeader(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Mascot(pose: 'search', size: 80),
            CardTitle(
              Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 32,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const CardDescription(
              Text(
                'No harm done. Tell us your email and we will send a link to choose a new one.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        CardContent(
          child: InkForm(
            controller: _form,
            semanticLabel: 'Reset your password',
            child: FieldGroup(
              children: [
                if (_formError case final message?)
                  Alert(
                    variant: AlertTone.destructive,
                    icon: const InkIcon('circle-alert'),
                    children: [
                      const AlertTitle(Text('That did not go through')),
                      AlertDescription(Text(message)),
                    ],
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
                        onChanged: (value) => _form.setValue('email', value),
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
                          false => 'Send reset link',
                        }),
                      ),
                    ),
                    const FieldDescription(
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(text: 'Remembered it? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: ForgotPassword01Link('Back to sign in'),
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
    );
  }
}
