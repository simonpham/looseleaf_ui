import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupStatesExample extends StatelessWidget {
  const RadioGroupStatesExample({super.key});

  static const _sizes = [
    (Spacing.d16, '16 px'),
    (Spacing.d20, '20 px'),
    (Spacing.d28, '28 px'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        for (final (size, name) in _sizes)
          Row(
            children: [
              SizedBox(
                width: Spacing.d56,
                child: Text(
                  name,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
              RadioGroup<String>(
                value: 'on',
                onChanged: (_) {},
                direction: Axis.horizontal,
                semanticLabel: name,
                children: [
                  RadioGroupItem(
                    value: 'off',
                    size: size,
                    semanticLabel: '$name off',
                  ),
                  RadioGroupItem(
                    value: 'on',
                    size: size,
                    semanticLabel: '$name on',
                  ),
                  RadioGroupItem(
                    value: 'bad',
                    size: size,
                    invalid: true,
                    semanticLabel: '$name invalid',
                  ),
                  RadioGroupItem(
                    value: 'locked',
                    size: size,
                    disabled: true,
                    semanticLabel: '$name disabled',
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
