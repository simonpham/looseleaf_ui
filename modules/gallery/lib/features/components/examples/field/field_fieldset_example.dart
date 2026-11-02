import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldFieldsetExample extends StatelessWidget {
  const FieldFieldsetExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const FieldSet(
      children: [
        FieldLegend(Text('Address Information')),
        FieldDescription(Text('We need your address to deliver your order.')),
        FieldGroup(
          children: [
            Field(
              children: [
                FieldLabel(child: Text('Street Address')),
                Input(placeholder: '123 Main St'),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Expanded(
                  child: Field(
                    children: [
                      FieldLabel(child: Text('City')),
                      Input(placeholder: 'New York'),
                    ],
                  ),
                ),
                Expanded(
                  child: Field(
                    children: [
                      FieldLabel(child: Text('Postal Code')),
                      Input(placeholder: '90502'),
                    ],
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
