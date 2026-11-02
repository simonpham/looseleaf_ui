import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfRadiogroupExample extends StatefulWidget {
  const FormRhfRadiogroupExample({super.key});

  @override
  State<FormRhfRadiogroupExample> createState() =>
      _FormRhfRadiogroupExampleState();
}

class _FormRhfRadiogroupExampleState extends State<FormRhfRadiogroupExample> {
  static const _maxWidth = 448.0;
  static const _plans = [
    (
      id: 'starter',
      title: 'Starter (100K tokens/month)',
      description: 'For everyday use with basic features.',
    ),
    (
      id: 'pro',
      title: 'Pro (1M tokens/month)',
      description: 'For advanced AI usage with more features.',
    ),
    (
      id: 'enterprise',
      title: 'Enterprise (Unlimited tokens)',
      description: 'For large teams and heavy usage.',
    ),
  ];

  final _form = FormController(initialValues: {'plan': ''});
  final _toasts = ToastController();

  @override
  void dispose() {
    _form.dispose();
    _toasts.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) => FormValuesToaster.show(_toasts, values)),
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
              CardTitle(Text('Subscription Plan')),
              CardDescription(Text('See pricing and features for each plan.')),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'plan',
                    validator: (value) => switch (value) {
                      null ||
                      '' => 'You must select a subscription plan to continue.',
                      _ => null,
                    },
                    builder: (context, field) => FieldSet(
                      children: [
                        const FieldLegend(Text('Plan')),
                        const FieldDescription(
                          Text(
                            'You can upgrade or downgrade your plan at any time.',
                          ),
                        ),
                        InkRadioGroup<String>(
                          value: field.value,
                          onChanged: field.onChanged,
                          invalid: field.invalid,
                          semanticLabel: 'Plan',
                          children: [
                            for (final plan in _plans)
                              FieldLabel(
                                checked: field.value == plan.id,
                                onPressed: () => field.onChanged(plan.id),
                                child: Field(
                                  orientation: FieldOrientation.horizontal,
                                  invalid: field.invalid,
                                  children: [
                                    FieldContent(
                                      children: [
                                        FieldTitle(Text(plan.title)),
                                        FieldDescription(
                                          Text(plan.description),
                                        ),
                                      ],
                                    ),
                                    InkRadioGroupItem(value: plan.id),
                                  ],
                                ),
                              ),
                          ],
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
