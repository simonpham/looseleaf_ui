import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldRadioExample extends StatefulWidget {
  const FieldRadioExample({super.key});

  @override
  State<FieldRadioExample> createState() => _FieldRadioExampleState();
}

class _FieldRadioExampleState extends State<FieldRadioExample> {
  static const _maxWidth = 448.0;
  static const _plans = [
    ('monthly', r'Monthly ($9.99/month)'),
    ('yearly', r'Yearly ($99.99/year)'),
    ('lifetime', r'Lifetime ($299.99)'),
  ];

  var _plan = 'monthly';

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldSet(
      children: [
        const FieldLegend(
          Text('Subscription Plan'),
          variant: FieldLegendVariant.label,
        ),
        const FieldDescription(
          Text('Yearly and lifetime plans offer significant savings.'),
        ),
        RadioGroup<String>(
          value: _plan,
          onChanged: (value) => setState(() => _plan = value),
          semanticLabel: 'Subscription Plan',
          children: [
            for (final (value, label) in _plans)
              Field(
                orientation: FieldOrientation.horizontal,
                children: [
                  RadioGroupItem(value: value),
                  FieldLabel(
                    onPressed: () => setState(() => _plan = value),
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}
