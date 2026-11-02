import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldChoiceCardsExample extends StatefulWidget {
  const FieldChoiceCardsExample({super.key});

  @override
  State<FieldChoiceCardsExample> createState() =>
      _FieldChoiceCardsExampleState();
}

class _FieldChoiceCardsExampleState extends State<FieldChoiceCardsExample> {
  static const _maxWidth = Spacing.d448;
  static const _plans = [
    ('starter', 'Starter', 'One notebook, one pen, no rush.'),
    ('studio', 'Studio', 'Ten notebooks and the good highlighters.'),
    ('workshop', 'Workshop', 'A whole desk. Washi tape included.'),
  ];

  var _plan = 'studio';
  var _newsletter = true;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        FieldSet(
          children: [
            const FieldLegend(
              Text('Plan'),
              variant: FieldLegendVariant.label,
            ),
            InkRadioGroup<String>(
              value: _plan,
              onChanged: (value) => setState(() => _plan = value),
              semanticLabel: 'Plan',
              children: [
                for (final (value, title, help) in _plans)
                  FieldLabel(
                    checked: _plan == value,
                    onPressed: () => setState(() => _plan = value),
                    child: Field(
                      orientation: FieldOrientation.horizontal,
                      children: [
                        FieldContent(
                          children: [
                            FieldTitle(Text(title)),
                            FieldDescription(Text(help)),
                          ],
                        ),
                        InkRadioGroupItem(value: value),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        FieldLabel(
          checked: _newsletter,
          onPressed: () => setState(() => _newsletter = !_newsletter),
          child: Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Checkbox(
                value: _newsletter,
                onChanged: (value) => setState(() => _newsletter = value),
              ),
              const FieldContent(
                children: [
                  FieldTitle(Text('Field notes newsletter')),
                  FieldDescription(Text('Twice a month, always in pencil.')),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
