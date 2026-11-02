import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfCheckboxExample extends StatefulWidget {
  const FormRhfCheckboxExample({super.key});

  @override
  State<FormRhfCheckboxExample> createState() => _FormRhfCheckboxExampleState();
}

class _FormRhfCheckboxExampleState extends State<FormRhfCheckboxExample> {
  static const _maxWidth = Spacing.d448;
  static const _normal = TextStyle(fontWeight: FontWeight.w400);
  static const _tasks = {
    'push': 'Push notifications',
    'email': 'Email notifications',
  };

  final _form = FormController(
    initialValues: {'responses': true, 'tasks': <String>[]},
  );
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

  String? _validateTasks(List<String>? value) {
    final tasks = value ?? const <String>[];
    if (tasks.isEmpty) return 'Please select at least one notification type.';
    if (!tasks.every(_tasks.containsKey)) {
      return 'Invalid notification type selected.';
    }
    return null;
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
              CardTitle(Text('Notifications')),
              CardDescription(Text('Manage your notification preferences.')),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<bool>(
                    name: 'responses',
                    builder: (context, field) => FieldSet(
                      children: [
                        const FieldLegend(
                          Text('Responses'),
                          variant: FieldLegendVariant.label,
                        ),
                        const FieldDescription(
                          Text(
                            'Get notified for requests that take time, like research or image generation.',
                          ),
                        ),
                        FieldGroup(
                          children: [
                            Field(
                              orientation: FieldOrientation.horizontal,
                              children: [
                                Checkbox(
                                  value: field.value ?? false,
                                  onChanged: field.onChanged,
                                  disabled: true,
                                ),
                                const FieldLabel(
                                  child: Text(
                                    'Push notifications',
                                    style: _normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const FieldSeparator(),
                  InkFormField<List<String>>(
                    name: 'tasks',
                    validator: _validateTasks,
                    builder: (context, field) {
                      final tasks = field.value ?? const <String>[];
                      void toggle(String id) => field.onChanged([
                        for (final task in tasks)
                          if (task != id) task,
                        if (!tasks.contains(id)) id,
                      ]);
                      return FieldGroup(
                        children: [
                          FieldSet(
                            children: [
                              const FieldLegend(
                                Text('Tasks'),
                                variant: FieldLegendVariant.label,
                              ),
                              const FieldDescription(
                                Text(
                                  "Get notified when tasks you've created have updates.",
                                ),
                              ),
                              FieldGroup(
                                children: [
                                  for (final MapEntry(key: id, value: label)
                                      in _tasks.entries)
                                    Field(
                                      orientation: FieldOrientation.horizontal,
                                      invalid: field.invalid,
                                      children: [
                                        Checkbox(
                                          value: tasks.contains(id),
                                          onChanged: (_) => toggle(id),
                                          invalid: field.invalid,
                                        ),
                                        FieldLabel(
                                          onPressed: () => toggle(id),
                                          child: Text(label, style: _normal),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (field.error case final error?)
                            FieldError(errors: [error]),
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
