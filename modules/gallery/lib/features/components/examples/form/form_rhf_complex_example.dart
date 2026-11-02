import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/form/form.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FormRhfComplexExample extends StatefulWidget {
  const FormRhfComplexExample({super.key});

  @override
  State<FormRhfComplexExample> createState() => _FormRhfComplexExampleState();
}

class _FormRhfComplexExampleState extends State<FormRhfComplexExample> {
  static const _maxWidth = Spacing.d384;
  static const _plans = [
    (
      id: 'basic',
      title: 'Basic',
      description: 'For individuals and small teams',
    ),
    (
      id: 'pro',
      title: 'Pro',
      description: 'For businesses with higher demands',
    ),
  ];
  static const _addons = [
    (
      id: 'analytics',
      title: 'Analytics',
      description: 'Advanced analytics and reporting',
    ),
    (id: 'backup', title: 'Backup', description: 'Automated daily backups'),
    (
      id: 'support',
      title: 'Priority Support',
      description: '24/7 premium customer support',
    ),
  ];

  final _form = FormController(
    initialValues: {
      'plan': 'basic',
      'billingPeriod': '',
      'addons': <String>[],
      'emailNotifications': false,
    },
  );
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

  String? _validatePlan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a subscription plan';
    }
    if (!_plans.any((plan) => plan.id == value)) {
      return 'Invalid plan selection. Please choose Basic or Pro';
    }
    return null;
  }

  String? _validateAddons(List<String>? value) {
    final addons = value ?? const <String>[];
    if (addons.isEmpty) return 'Please select at least one add-on';
    if (addons.length > 3) return 'You can select up to 3 add-ons';
    if (!addons.every((id) => _addons.any((addon) => addon.id == id))) {
      return 'You selected an invalid add-on';
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
            divider: true,
            children: [
              CardTitle(Text("You're almost there!")),
              CardDescription(
                Text('Choose your subscription plan and billing period.'),
              ),
            ],
          ),
          CardContent(
            child: InkForm(
              controller: _form,
              child: FieldGroup(
                children: [
                  InkFormField<String>(
                    name: 'plan',
                    validator: _validatePlan,
                    builder: (context, field) => FieldSet(
                      children: [
                        const FieldLegend(
                          Text('Subscription Plan'),
                          variant: FieldLegendVariant.label,
                        ),
                        const FieldDescription(
                          Text('Choose your subscription plan.'),
                        ),
                        InkRadioGroup<String>(
                          value: field.value,
                          onChanged: field.onChanged,
                          invalid: field.invalid,
                          semanticLabel: 'Subscription Plan',
                          children: [
                            for (final plan in _plans)
                              FieldLabel(
                                checked: field.value == plan.id,
                                onPressed: () => field.onChanged(plan.id),
                                child: Field(
                                  orientation: FieldOrientation.horizontal,
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
                  const FieldSeparator(),
                  InkFormField<String>(
                    name: 'billingPeriod',
                    validator: (value) => switch (value) {
                      null || '' => 'Please select a billing period',
                      _ => null,
                    },
                    builder: (context, field) => Field(
                      invalid: field.invalid,
                      children: [
                        const FieldLabel(child: Text('Billing Period')),
                        Select(
                          value: field.value,
                          onChanged: field.onChanged,
                          content: const SelectContent(
                            children: [
                              SelectItem(
                                value: 'monthly',
                                child: Text('Monthly'),
                              ),
                              SelectItem(
                                value: 'yearly',
                                child: Text('Yearly'),
                              ),
                            ],
                          ),
                          child: SelectTrigger(
                            invalid: field.invalid,
                            child: const SelectValue(placeholder: 'Select'),
                          ),
                        ),
                        const FieldDescription(
                          Text('Choose how often you want to be billed.'),
                        ),
                        if (field.error case final error?)
                          FieldError(errors: [error]),
                      ],
                    ),
                  ),
                  const FieldSeparator(),
                  InkFormField<List<String>>(
                    name: 'addons',
                    validator: _validateAddons,
                    builder: (context, field) {
                      final chosen = field.value ?? const <String>[];
                      void toggle(String id) => field.onChanged([
                        for (final addon in chosen)
                          if (addon != id) addon,
                        if (!chosen.contains(id)) id,
                      ]);
                      return FieldSet(
                        children: [
                          const FieldLegend(Text('Add-ons')),
                          const FieldDescription(
                            Text(
                              "Select additional features you'd like to include.",
                            ),
                          ),
                          FieldGroup(
                            children: [
                              for (final addon in _addons)
                                Field(
                                  orientation: FieldOrientation.horizontal,
                                  invalid: field.invalid,
                                  children: [
                                    Checkbox(
                                      value: chosen.contains(addon.id),
                                      onChanged: (_) => toggle(addon.id),
                                      invalid: field.invalid,
                                    ),
                                    FieldContent(
                                      children: [
                                        FieldLabel(
                                          onPressed: () => toggle(addon.id),
                                          child: Text(addon.title),
                                        ),
                                        FieldDescription(
                                          Text(addon.description),
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
                  const FieldSeparator(),
                  InkFormField<bool>(
                    name: 'emailNotifications',
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
                                child: const Text('Email Notifications'),
                              ),
                              const FieldDescription(
                                Text(
                                  'Receive email updates about your subscription',
                                ),
                              ),
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
            divider: true,
            children: [
              Expanded(
                child: Field(
                  children: [
                    Button(
                      onPressed: _submit,
                      child: const Text('Save Preferences'),
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: _form.reset,
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
