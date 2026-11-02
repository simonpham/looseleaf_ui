import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupPlansExample extends StatefulWidget {
  const RadioGroupPlansExample({super.key});

  @override
  State<RadioGroupPlansExample> createState() => _RadioGroupPlansExampleState();
}

class _RadioGroupPlansExampleState extends State<RadioGroupPlansExample> {
  static const _plans = [
    ('starter', 'Starter', 'One notebook, one pen, no rush.'),
    ('studio', 'Studio', 'Ten notebooks and the good highlighters.'),
    ('workshop', 'Workshop', 'A whole desk. Washi tape included.'),
  ];

  String _plan = 'studio';
  String _billing = 'yearly';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          InkRadioGroup<String>(
            value: _plan,
            onChanged: (value) => setState(() => _plan = value),
            semanticLabel: 'Plan',
            gap: Spacing.d16,
            children: [
              for (final (value, title, help) in _plans)
                InkRadioGroupItem(
                  value: value,
                  size: Spacing.d20,
                  label: Text(title),
                  description: Text(help),
                ),
            ],
          ),
          InkRadioGroup<String>(
            value: _billing,
            onChanged: (value) => setState(() => _billing = value),
            direction: Axis.horizontal,
            semanticLabel: 'Billing',
            children: const [
              InkRadioGroupItem(value: 'monthly', label: Text('Monthly')),
              InkRadioGroupItem(value: 'yearly', label: Text('Yearly')),
            ],
          ),
        ],
      ),
    );
  }
}
