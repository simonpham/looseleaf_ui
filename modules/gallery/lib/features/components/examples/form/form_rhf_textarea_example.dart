import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfTextareaExample extends StatefulWidget {
  const FormRhfTextareaExample({super.key});

  @override
  State<FormRhfTextareaExample> createState() => _FormRhfTextareaExampleState();
}

class _FormRhfTextareaExampleState extends State<FormRhfTextareaExample> {
  static const _maxWidth = 448.0;

  final _form = FormController(initialValues: {'about': ''});
  final _about = TextEditingController();
  final _aboutFocus = FocusNode();
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _about.dispose();
    _aboutFocus.dispose();
    _toasts.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) => FormValuesToaster.show(_toasts, values)),
  );

  void _reset() {
    _form.reset();
    _about.clear();
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
              CardTitle(Text('Personalization')),
              CardDescription(
                Text(
                  'Customize your experience by telling us more about yourself.',
                ),
              ),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'about',
                    validator: (value) => switch ((value ?? '').length) {
                      < 10 => 'Please provide at least 10 characters.',
                      > 200 => 'Please keep it under 200 characters.',
                      _ => null,
                    },
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        FieldLabel(
                          focusNode: _aboutFocus,
                          child: const Text('More about you'),
                        ),
                        Textarea(
                          controller: _about,
                          focusNode: _aboutFocus,
                          invalid: field.invalid,
                          ruled: true,
                          placeholder: "I'm a software engineer...",
                          onChanged: field.onChanged,
                        ),
                        const FieldDescription(
                          Text(
                            'Tell us more about yourself. This will be used to help us personalize your experience.',
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
