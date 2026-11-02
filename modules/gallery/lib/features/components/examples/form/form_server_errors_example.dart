import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormServerErrorsExample extends StatefulWidget {
  const FormServerErrorsExample({super.key});

  @override
  State<FormServerErrorsExample> createState() =>
      _FormServerErrorsExampleState();
}

class _FormServerErrorsExampleState extends State<FormServerErrorsExample> {
  static const _maxWidth = Spacing.d384;
  static const _taken = ['ada', 'grace', 'notes'];
  static final _handlePattern = RegExp(r'^[a-z0-9_]+$');

  final _form = FormController(initialValues: {'handle': 'notes'});
  final _handle = TextEditingController(text: 'notes');
  var _pending = false;
  var _done = '';

  @override
  void dispose() {
    _form.dispose();
    _handle.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final handle = value ?? '';
    if (handle.length < 3) return 'At least 3 characters.';
    if (!_handlePattern.hasMatch(handle)) {
      return 'Lowercase letters, numbers and _ only.';
    }
    return null;
  }

  void _onChanged(String value) {
    _form
      ..setValue('handle', value)
      ..validate('handle');
  }

  Future<void> _claim(Map<String, Object?> values) async {
    final handle = values['handle'];
    setState(() {
      _pending = true;
      _done = '';
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _pending = false);
    if (_taken.contains(handle)) {
      _form.setError('handle', '@$handle is already taken.');
      return;
    }
    setState(() => _done = '@$handle is yours.');
  }

  void _submit() {
    if (_pending) return;
    unawaited(_form.handleSubmit(_claim));
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: InkForm(
        controller: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            InkFormField<String>(
              name: 'handle',
              validator: _validate,
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Handle')),
                  FormControl(
                    child: Input(
                      controller: _handle,
                      invalid: field.invalid,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const FormDescription(
                    Text('Try "notes" (taken), then something else.'),
                  ),
                  const FormMessage(),
                ],
              ),
            ),
            Row(
              spacing: Spacing.d12,
              children: [
                Button(
                  onPressed: _submit,
                  child: Text(switch (_pending) {
                    true => 'Checking',
                    false => 'Claim it',
                  }),
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _done,
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
