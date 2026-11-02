import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/reset_password_01/reset_password_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A new password with a live checklist, typed twice; then a "done" card.
///
/// Mirrors upstream
/// `src/blocks/reset-password-01/components/reset-password-01-form.tsx`.
class ResetPassword01Form extends StatefulWidget {
  const ResetPassword01Form({super.key, this.onSubmit});

  /// Saves the new password; a thrown error's message shows in the card.
  final Future<void> Function(String password)? onSubmit;

  @override
  State<ResetPassword01Form> createState() => _ResetPassword01FormState();
}

class _ResetPassword01FormState extends State<ResetPassword01Form> {
  final _form = FormController(
    initialValues: {'password': '', 'confirm': ''},
    mode: FormValidationMode.onTouched,
  );
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _titleFocus = FocusNode();
  String? _formError;
  bool _saved = false;

  @override
  void dispose() {
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _titleFocus.dispose();
    _form.dispose();
    super.dispose();
  }

  void _changePassword(String value) {
    _form.setValue('password', value);
    if ((_form.value<String>('confirm') ?? '').isEmpty) return;
    _form.validate('confirm');
  }

  static String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'\d').hasMatch(password)) return 'Add at least one number.';
    if (!RegExp('[a-z]').hasMatch(password) ||
        !RegExp('[A-Z]').hasMatch(password)) {
      return 'Mix a capital and a small letter.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'Type the password once more.';
    if (confirm != _form.value<String>('password')) {
      return 'Those two do not match yet.';
    }
    return null;
  }

  static Future<void> _pretend(String password) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  Future<void> _save(Map<String, Object?> values) async {
    setState(() => _formError = null);
    try {
      await (widget.onSubmit ?? _pretend)('${values['password'] ?? ''}');
      if (!mounted) return;
      setState(() => _saved = true);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _titleFocus.requestFocus(),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final message = '$error';
      setState(
        () => _formError = switch (message.isEmpty) {
          true =>
            'We could not save the new password. Ask for a fresh link and try again.',
          false => message,
        },
      );
    }
  }

  void _submit() => unawaited(_form.handleSubmit(_save));

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return ResetPassword01Done(
        titleFocus: _titleFocus,
        demo: widget.onSubmit == null,
      );
    }
    final theme = LooseleafTheme.of(context);
    return Card(
      tape: PaperTape.corner,
      seed: 'reset-password-01',
      children: [
        CardHeader(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Mascot(pose: 'write', size: 80),
            CardTitle(
              Text(
                'Choose a new password',
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
                'Make it one you will remember. Nobody is watching the pen.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        CardContent(
          child: InkForm(
            controller: _form,
            semanticLabel: 'Choose a new password',
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
                  name: 'password',
                  validator: _validatePassword,
                  builder: (context, field) => Field(
                    invalid: field.invalid,
                    children: [
                      FieldLabel(
                        focusNode: _passwordFocus,
                        child: const Text('New password'),
                      ),
                      ResetPassword01PasswordInput(
                        focusNode: _passwordFocus,
                        invalid: field.invalid,
                        semanticLabel: 'New password',
                        onChanged: _changePassword,
                      ),
                      ResetPassword01Rules(password: field.value ?? ''),
                      FieldError(errors: [field.error]),
                    ],
                  ),
                ),
                InkFormField<String>(
                  name: 'confirm',
                  validator: _validateConfirm,
                  builder: (context, field) => Field(
                    invalid: field.invalid,
                    children: [
                      FieldLabel(
                        focusNode: _confirmFocus,
                        child: const Text('Confirm new password'),
                      ),
                      ResetPassword01PasswordInput(
                        focusNode: _confirmFocus,
                        invalid: field.invalid,
                        semanticLabel: 'Confirm new password',
                        toggleLabel: 'Show password confirmation',
                        onChanged: (value) => _form.setValue('confirm', value),
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
                          true => 'Saving',
                          false => 'Save new password',
                        }),
                      ),
                    ),
                    const FieldDescription(
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(text: 'Changed your mind? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: ResetPassword01Link('Back to sign in'),
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
