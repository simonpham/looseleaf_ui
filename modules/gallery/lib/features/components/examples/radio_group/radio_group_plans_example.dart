import 'package:flutter/widgets.dart' hide RadioGroup;
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
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          RadioGroup<String>(
            value: _plan,
            onChanged: (value) => setState(() => _plan = value),
            semanticLabel: 'Plan',
            children: [
              for (final (value, title, help) in _plans)
                RadioGroupItem(
                  value: value,
                  size: Spacing.d20,
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d4,
                    children: [
                      Text(title),
                      Text(
                        help,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          RadioGroup<String>(
            value: _billing,
            onChanged: (value) => setState(() => _billing = value),
            direction: Axis.horizontal,
            semanticLabel: 'Billing',
            children: const [
              RadioGroupItem(value: 'monthly', label: Text('Monthly')),
              RadioGroupItem(value: 'yearly', label: Text('Yearly')),
            ],
          ),
        ],
      ),
    );
  }
}
