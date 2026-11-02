import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfDemoExample extends StatefulWidget {
  const FormRhfDemoExample({super.key});

  @override
  State<FormRhfDemoExample> createState() => _FormRhfDemoExampleState();
}

class _FormRhfDemoExampleState extends State<FormRhfDemoExample> {
  static const _maxWidth = Spacing.d448;

  final _form = FormController(
    initialValues: {'title': '', 'description': ''},
  );
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _titleFocus = FocusNode();
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _title.dispose();
    _description.dispose();
    _titleFocus.dispose();
    _toasts.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    _form.handleSubmit(
      (values) => FormValuesToaster.show(_toasts, values),
    ),
  );

  void _reset() {
    _form.reset();
    _title.clear();
    _description.clear();
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
              CardTitle(Text('Bug Report')),
              CardDescription(
                Text('Help us improve by reporting bugs you encounter.'),
              ),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'title',
                    validator: (value) => switch ((value ?? '').length) {
                      < 5 => 'Bug title must be at least 5 characters.',
                      > 32 => 'Bug title must be at most 32 characters.',
                      _ => null,
                    },
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        FieldLabel(
                          focusNode: _titleFocus,
                          child: const Text('Bug Title'),
                        ),
                        Input(
                          controller: _title,
                          focusNode: _titleFocus,
                          invalid: field.invalid,
                          placeholder: 'Login button not working on mobile',
                          onChanged: field.onChanged,
                        ),
                        if (field.error case final error?)
                          FieldError(errors: [error]),
                      ],
                    ),
                  ),
                  InkFormField<String>(
                    name: 'description',
                    validator: (value) => switch ((value ?? '').length) {
                      < 20 => 'Description must be at least 20 characters.',
                      > 100 => 'Description must be at most 100 characters.',
                      _ => null,
                    },
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        const FieldLabel(child: Text('Description')),
                        InputGroup(
                          invalid: field.invalid,
                          children: [
                            InputGroupTextarea(
                              controller: _description,
                              placeholder: "I'm having an issue with the login button on mobile.",
                              minLines: 4,
                              onChanged: field.onChanged,
                            ),
                            InputGroupAddon(
                              align: InputGroupAlign.blockEnd,
                              child: InputGroupText(
                                child: Text(
                                  '${field.value?.length ?? 0}/100 characters',
                                  style: const TextStyle(
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const FieldDescription(
                          Text(
                            'Include steps to reproduce, expected behavior, and what actually happened.',
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
                    Button(onPressed: _submit, child: const Text('Submit')),
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
