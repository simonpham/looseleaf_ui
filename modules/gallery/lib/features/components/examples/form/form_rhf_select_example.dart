import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfSelectExample extends StatefulWidget {
  const FormRhfSelectExample({super.key});

  @override
  State<FormRhfSelectExample> createState() => _FormRhfSelectExampleState();
}

class _FormRhfSelectExampleState extends State<FormRhfSelectExample> {
  static const _maxWidth = Spacing.d512;
  static const _triggerMinWidth = 120.0;
  static const _spokenLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'zh': 'Chinese',
    'ja': 'Japanese',
  };

  final _form = FormController(initialValues: {'language': ''});
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _toasts.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    _form.handleSubmit(
      (values) => FormValuesToaster.show(_toasts, values),
    ),
  );

  @override
  Widget build(BuildContext context) => FormValuesToaster(
    controller: _toasts,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Language Preferences')),
              CardDescription(Text('Select your preferred spoken language.')),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'language',
                    validator: (value) => switch (value) {
                      null || '' => 'Please select your spoken language.',
                      'auto' => 'Auto-detection is not allowed. Please select a specific language.',
                      _ => null,
                    },
                    builder: (context, field) => Field(
                      orientation: FieldOrientation.responsive,
                      invalid: field.invalid,
                      children: [
                        FieldContent(
                          children: [
                            const FieldLabel(child: Text('Spoken Language')),
                            const FieldDescription(
                              Text(
                                'For best results, select the language you speak.',
                              ),
                            ),
                            if (field.error case final error?)
                              FieldError(errors: [error]),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: _triggerMinWidth,
                          ),
                          child: Select(
                            value: field.value,
                            onChanged: field.onChanged,
                            content: SelectContent(
                              children: [
                                const SelectItem(
                                  value: 'auto',
                                  child: Text('Auto'),
                                ),
                                const SelectSeparator(),
                                for (final MapEntry(:key, :value)
                                    in _spokenLanguages.entries)
                                  SelectItem(value: key, child: Text(value)),
                              ],
                            ),
                            child: SelectTrigger(
                              invalid: field.invalid,
                              child: const SelectValue(placeholder: 'Select'),
                            ),
                          ),
                        ),
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
                      onPressed: _form.reset,
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
