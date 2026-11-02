import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MascotSizesExample extends StatelessWidget {
  const MascotSizesExample({super.key});

  static const _sizes = <double>[24, 32, 48, 96, 160];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: Spacing.d32,
      runSpacing: Spacing.d24,
      children: [
        for (final size in _sizes)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              Mascot(size: size),
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
    );
  }
}
