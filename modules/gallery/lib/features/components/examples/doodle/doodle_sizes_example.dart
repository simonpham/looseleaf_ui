import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DoodleSizesExample extends StatelessWidget {
  const DoodleSizesExample({super.key});

  static const _sizes = <double>[32, 48, 64, 96, 128];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        for (final name in const ['sun', 'mushroom'])
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
                    Doodle(name, size: size),
                    Text(
                      '${size.toInt()}',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.pencilText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
