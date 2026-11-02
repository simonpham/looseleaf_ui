import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfSwitchExample extends StatefulWidget {
  const FormRhfSwitchExample({super.key});

  @override
  State<FormRhfSwitchExample> createState() => _FormRhfSwitchExampleState();
}

class _FormRhfSwitchExampleState extends State<FormRhfSwitchExample> {
  static const _maxWidth = Spacing.d448;

  final _form = FormController(initialValues: {'twoFactor': false});
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
              CardTitle(Text('Security Settings')),
              CardDescription(
                Text('Manage your account security preferences.'),
              ),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<bool>(
                    name: 'twoFactor',
                    validator: (value) => switch (value) {
                      true => null,
                      _ => 'It is highly recommended to enable two-factor authentication.',
                    },
                    builder: (context, field) {
                      final enabled = field.value ?? false;
                      return Field(
                        orientation: FieldOrientation.horizontal,
                        invalid: field.invalid,
                        children: [
                          FieldContent(
                            children: [
                              FieldLabel(
                                onPressed: () => field.onChanged(!enabled),
                                child: const Text(
                                  'Multi-factor authentication',
                                ),
                              ),
                              const FieldDescription(
                                Text(
                                  'Enable multi-factor authentication to secure your account.',
                                ),
                              ),
                              if (field.error case final error?)
                                FieldError(errors: [error]),
                            ],
                          ),
                          Switch(
                            value: enabled,
                            onChanged: field.onChanged,
                            invalid: field.invalid,
                          ),
                        ],
                      );
                    },
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
