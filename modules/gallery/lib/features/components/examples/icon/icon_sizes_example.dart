import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _names = ['check', 'search', 'triangle-alert', 'settings'];

const _sizes = [
  Spacing.d12,
  Spacing.d16,
  Spacing.d20,
  Spacing.d24,
  Spacing.d32,
  Spacing.d48,
];

class IconSizesExample extends StatelessWidget {
  const IconSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final caption = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.pencilText,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        for (final name in _names)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: Spacing.d24,
            runSpacing: Spacing.d16,
            children: [
              for (final size in _sizes)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d4,
                  children: [
                    InkIcon(name, size: size),
                    Text('${size.toInt()}', style: caption),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
