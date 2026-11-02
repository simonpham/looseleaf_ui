import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfArrayExample extends StatefulWidget {
  const FormRhfArrayExample({super.key});

  @override
  State<FormRhfArrayExample> createState() => _FormRhfArrayExampleState();
}

class _FormRhfArrayExampleState extends State<FormRhfArrayExample> {
  static const _maxWidth = Spacing.d448;
  static const _maxEmails = 5;
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = FormController(
    initialValues: {'email-0': '', 'email-1': ''},
  );
  final _toasts = ToastController();
  final _addresses = {
    0: TextEditingController(),
    1: TextEditingController(),
  };
  var _nextId = 2;

  @override
  void dispose() {
    _form.dispose();
    _toasts.dispose();
    for (final address in _addresses.values) {
      address.dispose();
    }
    super.dispose();
  }

  void _append() => setState(() {
    final id = _nextId++;
    _addresses[id] = TextEditingController();
    _form.setValue('email-$id', '');
  });

  void _remove(int id) => setState(() {
    _addresses.remove(id)?.dispose();
  });

  void _reset() => setState(() {
    final first = {
      0: _addresses.remove(0) ?? TextEditingController(),
      1: _addresses.remove(1) ?? TextEditingController(),
    };
    for (final address in _addresses.values) {
      address.dispose();
    }
    _addresses
      ..clear()
      ..addAll(first);
    for (final address in first.values) {
      address.clear();
    }
    _form.reset();
  });

  void _submit() => unawaited(
    _form.handleSubmit(
      (values) => FormValuesToaster.show(_toasts, {
        'emails': [
          for (final id in _addresses.keys) {'address': values['email-$id']},
        ],
      }),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ids = _addresses.keys.toList();
    return FormValuesToaster(
      controller: _toasts,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          children: [
            const CardHeader(
              divider: true,
              children: [
                CardTitle(Text('Contact Emails')),
                CardDescription(Text('Manage your contact email addresses.')),
              ],
            ),
            CardContent(
              child: InkForm(
                controller: _form,
                child: FieldSet(
                  children: [
                    const FieldLegend(
                      Text('Email Addresses'),
                      variant: FieldLegendVariant.label,
                    ),
                    const FieldDescription(
                      Text(
                        'Add up to 5 email addresses where we can contact you.',
                      ),
                    ),
                    FieldGroup(
                      children: [
                        for (final (index, id) in ids.indexed)
                          InkFormField<String>(
                            key: ValueKey(id),
                            name: 'email-$id',
                            validator: (value) => switch (value) {
                              final email? when _emailPattern.hasMatch(email) =>
                                null,
                              _ => 'Enter a valid email address.',
                            },
                            builder: (context, field) => Field(
                              orientation: FieldOrientation.horizontal,
                              invalid: field.invalid,
                              children: [
                                FieldContent(
                                  children: [
                                    InputGroup(
                                      invalid: field.invalid,
                                      children: [
                                        InputGroupInput(
                                          controller: _addresses[id],
                                          placeholder: 'name@example.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          semanticLabel:
                                              'Email address ${index + 1}',
                                          onChanged: field.onChanged,
                                        ),
                                        if (ids.length > 1)
                                          InputGroupAddon(
                                            align: InputGroupAlign.inlineEnd,
                                            child: InputGroupButton(
                                              size: InputGroupButtonSize.iconXs,
                                              semanticLabel:
                                                  'Remove email ${index + 1}',
                                              onPressed: () => _remove(id),
                                              child: const InkIcon('x'),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (field.error case final error?)
                                      FieldError(errors: [error]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Button(
                          variant: ButtonVariant.outline,
                          size: ButtonSize.sm,
                          disabled: ids.length >= _maxEmails,
                          onPressed: _append,
                          child: const Text('Add Email Address'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CardFooter(
              divider: true,
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
}
