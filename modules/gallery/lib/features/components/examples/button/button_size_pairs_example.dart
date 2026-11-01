import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonSizePairsExample extends StatelessWidget {
  const ButtonSizePairsExample({super.key});

  static const _pairs = [
    ('Extra small', ButtonSize.xs, ButtonSize.iconXs, Spacing.d12),
    ('Small', ButtonSize.sm, ButtonSize.iconSm, Spacing.d16),
    ('Default', ButtonSize.regular, ButtonSize.icon, Spacing.d16),
    ('Large', ButtonSize.lg, ButtonSize.iconLg, Spacing.d20),
  ];

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d40,
    runSpacing: Spacing.d32,
    children: [
      for (final (label, size, iconSize, px) in _pairs)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Button(
              variant: ButtonVariant.outline,
              size: size,
              onPressed: () {},
              child: Text(label),
            ),
            Button(
              variant: ButtonVariant.outline,
              size: iconSize,
              semanticLabel: 'Send, ${label.toLowerCase()}',
              onPressed: () {},
              child: InkIcon('arrow-up-right', size: px),
            ),
          ],
        ),
    ],
  );
}
