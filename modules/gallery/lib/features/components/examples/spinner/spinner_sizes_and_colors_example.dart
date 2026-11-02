import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerSizesAndColorsExample extends StatelessWidget {
  const SpinnerSizesAndColorsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        const Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d24,
          runSpacing: Spacing.d16,
          children: [
            Spinner(size: Spacing.d12, semanticLabel: 'Loading, extra small'),
            Spinner(),
            Spinner(size: Spacing.d24, semanticLabel: 'Loading, medium'),
            Spinner(size: Spacing.d32, semanticLabel: 'Loading, large'),
            Spinner(size: Spacing.d48, semanticLabel: 'Loading, extra large'),
            Spinner(size: Spacing.d64, semanticLabel: 'Loading, huge'),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d24,
          runSpacing: Spacing.d16,
          children: [
            for (final (color, name) in [
              (colors.inkYou, 'blue'),
              (colors.red, 'red'),
              (colors.green, 'green'),
              (colors.pencilText, 'pencil'),
            ])
              DefaultTextStyle.merge(
                style: TextStyle(color: color),
                child: Spinner(
                  size: Spacing.d32,
                  semanticLabel: 'Loading, $name',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
