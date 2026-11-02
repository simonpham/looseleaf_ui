import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

typedef _Requirement = ({String label, RegExp pattern});

class FormRhfPasswordExample extends StatefulWidget {
  const FormRhfPasswordExample({super.key});

  @override
  State<FormRhfPasswordExample> createState() => _FormRhfPasswordExampleState();
}

class _FormRhfPasswordExampleState extends State<FormRhfPasswordExample> {
  static const _maxWidth = 448.0;
  static final _requirements = <_Requirement>[
    (label: 'At least 8 characters', pattern: RegExp(r'^.{8,}$')),
    (label: 'One lowercase letter', pattern: RegExp('[a-z]')),
    (label: 'One uppercase letter', pattern: RegExp('[A-Z]')),
    (label: 'One number', pattern: RegExp(r'\d')),
    (
      label: 'One special character',
      pattern: RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    ),
  ];
  static const _messages = [
    'Password must be at least 8 characters',
    'Password must contain at least one lowercase letter',
    'Password must contain at least one uppercase letter',
    'Password must contain at least one number',
    'Password must contain at least one special character',
  ];

  final _form = FormController(initialValues: {'password': ''});
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    _toasts.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    for (final (index, requirement) in _requirements.indexed) {
      if (!requirement.pattern.hasMatch(value ?? '')) return _messages[index];
    }
    return null;
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) => FormValuesToaster.show(_toasts, values)),
  );

  void _reset() {
    _form.reset();
    _password.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return FormValuesToaster(
      controller: _toasts,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          children: [
            const CardHeader(
              divider: true,
              children: [
                CardTitle(Text('Create Password')),
                CardDescription(
                  Text('Choose a strong password to secure your account.'),
                ),
              ],
            ),
            CardContent(
              child: InkForm(
                controller: _form,
                child: FieldGroup(
                  children: [
                    InkFormField<String>(
                      name: 'password',
                      validator: _validate,
                      builder: (context, field) {
                        final password = field.value ?? '';
                        final met = [
                          for (final requirement in _requirements)
                            requirement.pattern.hasMatch(password),
                        ];
                        final metCount = met.where((isMet) => isMet).length;
                        final strength = metCount / _requirements.length * 100;
                        final allMet = metCount == _requirements.length;
                        return Field(
                          invalid: field.invalid,
                          children: [
                            FieldLabel(
                              focusNode: _passwordFocus,
                              child: const Text('Password'),
                            ),
                            InputGroup(
                              focusNode: _passwordFocus,
                              invalid: field.invalid,
                              children: [
                                InputGroupInput(
                                  controller: _password,
                                  obscureText: true,
                                  placeholder: 'Enter your password',
                                  onChanged: field.onChanged,
                                ),
                                InputGroupAddon(
                                  align: InputGroupAlign.inlineEnd,
                                  child: InkIcon(
                                    'check',
                                    color: switch (allMet) {
                                      true => theme.colors.green,
                                      false => theme.colors.inkMuted,
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: Spacing.d8,
                              children: [
                                Progress(
                                  value: strength,
                                  tone: switch (strength) {
                                    <= 40 => ProgressTone.marker,
                                    <= 80 => ProgressTone.hi,
                                    _ => ProgressTone.green,
                                  },
                                  semanticLabel: 'Password strength',
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Spacing.d6,
                                  children: [
                                    for (final (index, requirement)
                                        in _requirements.indexed)
                                      _RequirementRow(
                                        label: requirement.label,
                                        met: met[index],
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
              divider: true,
              children: [
                Expanded(
                  child: Field(
                    children: [
                      Button(
                        onPressed: _submit,
                        child: const Text('Create Password'),
                      ),
                      Button(
                        variant: ButtonVariant.outline,
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
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

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final typography = LooseleafTheme.of(context).typography;
    return Semantics(
      label: switch (met) {
        true => '$label (met)',
        false => '$label (not met)',
      },
      excludeSemantics: true,
      child: Row(
        spacing: Spacing.d8,
        children: [
          InkIcon(
            switch (met) {
              true => 'check',
              false => 'x',
            },
            size: Spacing.d16,
            color: switch (met) {
              true => colors.green,
              false => colors.inkMuted,
            },
          ),
          Text(
            label,
            style: typography.interface(
              cssSize: 14,
              color: switch (met) {
                true => colors.ink,
                false => colors.inkMuted,
              },
            ),
          ),
        ],
      ),
    );
  }
}
