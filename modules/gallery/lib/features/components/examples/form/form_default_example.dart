import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormDefaultExample extends StatefulWidget {
  const FormDefaultExample({super.key});

  @override
  State<FormDefaultExample> createState() => _FormDefaultExampleState();
}

class _FormDefaultExampleState extends State<FormDefaultExample> {
  static const _maxWidth = Spacing.d384;
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = FormController(initialValues: {'username': '', 'email': ''});
  var _saved = '';

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _save() => unawaited(
    _form.handleSubmit(
      (values) => setState(
        () => _saved = 'Saved ${values['username']} <${values['email']}>',
      ),
    ),
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
              name: 'username',
              validator: (value) => switch (value) {
                final name? when name.length >= 2 => null,
                _ => 'Your name needs at least 2 letters.',
              },
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Name')),
                  FormControl(
                    child: Input(
                      placeholder: 'Ada',
                      invalid: field.invalid,
                      onChanged: field.onChanged,
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                  const FormDescription(Text('Shown on the pages you write.')),
                  const FormMessage(),
                ],
              ),
            ),
            InkFormField<String>(
              name: 'email',
              validator: (value) => switch (value) {
                final email? when _emailPattern.hasMatch(email) => null,
                _ => 'Enter an address like ada@notes.dev.',
              },
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Email')),
                  FormControl(
                    child: Input(
                      placeholder: 'ada@notes.dev',
                      keyboardType: TextInputType.emailAddress,
                      invalid: field.invalid,
                      onChanged: field.onChanged,
                      onSubmitted: (_) => _save(),
                    ),
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
