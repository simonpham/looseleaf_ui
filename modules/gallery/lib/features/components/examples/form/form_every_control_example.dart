import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormEveryControlExample extends StatefulWidget {
  const FormEveryControlExample({super.key});

  @override
  State<FormEveryControlExample> createState() =>
      _FormEveryControlExampleState();
}

class _FormEveryControlExampleState extends State<FormEveryControlExample> {
  static const _maxWidth = 384.0;
  static const _plans = {'starter': 'Starter', 'studio': 'Studio'};

  final _form = FormController(
    initialValues: {
      'role': '',
      'terms': false,
      'digest': true,
      'pages': [20.0],
    },
  );
  var _saved = '';

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _save() => unawaited(
    _form.handleSubmit((values) {
      final pages = values['pages'] as List<double>;
      setState(
        () => _saved =
            'Saved: ${values['role']}, ${values['plan']}, '
            '${pages.first.round()} pages',
      );
    }),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: InkForm(
        controller: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d20,
          children: [
            InkFormField<String>(
              name: 'role',
              validator: (value) => switch (value) {
                final role? when role.isNotEmpty => null,
                _ => 'Pick a role.',
              },
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Role')),
                  FormControl(
                    child: Select(
                      value: field.value,
                      onChanged: field.onChanged,
                      content: const SelectContent(
                        position: SelectPosition.popper,
                        children: [
                          SelectItem(value: 'author', child: Text('Author')),
                          SelectItem(value: 'editor', child: Text('Editor')),
                        ],
                      ),
                      child: SelectTrigger(
                        invalid: field.invalid,
                        child: const SelectValue(placeholder: 'Pick a role'),
                      ),
                    ),
                  ),
                  const FormMessage(),
                ],
              ),
            ),
            InkFormField<String>(
              name: 'plan',
              validator: (value) => switch (value) {
                null => 'Choose a plan.',
                _ => null,
              },
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Plan')),
                  FormControl(
                    child: InkRadioGroup<String>(
                      value: field.value,
                      onChanged: field.onChanged,
                      invalid: field.invalid,
                      semanticLabel: 'Plan',
                      children: [
                        for (final MapEntry(:key, :value) in _plans.entries)
                          InkRadioGroupItem(value: key, label: Text(value)),
                      ],
                    ),
                  ),
                  const FormMessage(),
                ],
              ),
            ),
            InkFormField<List<double>>(
              name: 'pages',
              validator: (value) => switch (value) {
                [final pages, ...] when pages >= 5 => null,
                _ => 'Aim for at least 5 pages a day.',
              },
              builder: (context, field) {
                final pages = field.value ?? const [20.0];
                return FormItem(
                  children: [
                    FormLabel(Text('Pages per day: ${pages.first.round()}')),
                    FormControl(
                      child: Slider(
                        values: pages,
                        onChanged: field.onChanged,
                        min: 1,
                        max: 60,
                        invalid: field.invalid,
                        semanticLabel: 'Pages per day',
                      ),
                    ),
                    const FormMessage(),
                  ],
                );
              },
            ),
            InkFormField<bool>(
              name: 'digest',
              builder: (context, field) => FormItem(
                children: [
                  Row(
                    spacing: Spacing.d16,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Spacing.d4,
                          children: [
                            FormLabel(Text('Weekly digest')),
                            FormDescription(Text('Sunday, in pencil.')),
                          ],
                        ),
                      ),
                      FormControl(
                        child: Switch(
                          value: field.value ?? false,
                          onChanged: field.onChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkFormField<bool>(
              name: 'terms',
              validator: (value) => switch (value) {
                true => null,
                _ => 'You must accept the terms.',
              },
              builder: (context, field) => FormItem(
                children: [
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      FormControl(
                        child: Checkbox(
                          value: field.value ?? false,
                          onChanged: field.onChanged,
                          invalid: field.invalid,
                        ),
                      ),
                      const Expanded(
                        child: FormLabel(Text('I accept the small print')),
                      ),
                    ],
                  ),
                  const FormMessage(),
                ],
              ),
            ),
            Row(
              spacing: Spacing.d12,
              children: [
                Button(onPressed: _save, child: const Text('Save')),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _saved,
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
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
