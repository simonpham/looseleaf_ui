import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupSizesExample extends StatelessWidget {
  const ButtonGroupSizesExample({super.key});

  static const _rows = [
    ('Extra small', ButtonSize.xs, ButtonSize.iconXs),
    ('Small', ButtonSize.sm, ButtonSize.iconSm),
    ('Default', ButtonSize.regular, ButtonSize.icon),
    ('Large', ButtonSize.lg, ButtonSize.iconLg),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d32,
    children: [
      for (final (label, size, iconSize) in _rows)
        ButtonGroup(
          semanticLabel: label,
          children: [
            for (final text in [label, 'Button', 'Group'])
              Button(
                variant: ButtonVariant.outline,
                size: size,
                onPressed: () {},
                child: Text(text),
              ),
            Button(
              variant: ButtonVariant.outline,
              size: iconSize,
              semanticLabel: 'Add',
              onPressed: () {},
              child: const InkIcon('plus'),
            ),
          ],
        ),
    ],
  );
}
