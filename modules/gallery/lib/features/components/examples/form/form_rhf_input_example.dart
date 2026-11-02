import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfInputExample extends StatefulWidget {
  const FormRhfInputExample({super.key});

  @override
  State<FormRhfInputExample> createState() => _FormRhfInputExampleState();
}

class _FormRhfInputExampleState extends State<FormRhfInputExample> {
  static const _maxWidth = Spacing.d448;
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');

  final _form = FormController(initialValues: {'username': ''});
  final _username = TextEditingController();
  final _usernameFocus = FocusNode();
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _username.dispose();
    _usernameFocus.dispose();
    _toasts.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final username = value ?? '';
    if (username.length < 3) return 'Username must be at least 3 characters.';
    if (username.length > 10) return 'Username must be at most 10 characters.';
    if (!_usernamePattern.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores.';
    }
    return null;
  }

  void _submit() => unawaited(
    _form.handleSubmit(
      (values) => FormValuesToaster.show(_toasts, values),
    ),
  );

  void _reset() {
    _form.reset();
    _username.clear();
  }

  @override
  Widget build(BuildContext context) => FormValuesToaster(
    controller: _toasts,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Profile Settings')),
              CardDescription(Text('Update your profile information below.')),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'username',
                    validator: _validate,
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        FieldLabel(
                          focusNode: _usernameFocus,
                          child: const Text('Username'),
                        ),
                        Input(
                          controller: _username,
                          focusNode: _usernameFocus,
                          invalid: field.invalid,
                          placeholder: 'shadcn',
                          autofillHints: const [AutofillHints.username],
                          onChanged: field.onChanged,
                          onSubmitted: (_) => _submit(),
                        ),
                        const FieldDescription(
                          Text(
                            'This is your public display name. Must be between 3 and 10 characters. Must only contain letters, numbers, and underscores.',
                          ),
                        ),
                        if (field.error case final error?)
                          FieldError(errors: [error]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CardFooter(
            children: [
              Expanded(
                child: Field(
                  orientation: FieldOrientation.horizontal,
                  children: [
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                    Button(onPressed: _submit, child: const Text('Save')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
