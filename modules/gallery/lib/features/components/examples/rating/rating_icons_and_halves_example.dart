import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RatingIconsAndHalvesExample extends StatelessWidget {
  const RatingIconsAndHalvesExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Rating(
            initialValue: 3.5,
            allowHalf: true,
            semanticLabel: 'Stars, halves allowed',
          ),
          Rating(
            icon: RatingIcon.heart,
            initialValue: 4,
            semanticLabel: 'Hearts',
          ),
          Rating(icon: RatingIcon.sun, initialValue: 2, semanticLabel: 'Suns'),
        ],
      ),
      Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Rating(size: RatingSize.sm, initialValue: 4, semanticLabel: 'Small'),
          Rating(size: RatingSize.lg, initialValue: 4, semanticLabel: 'Large'),
          Rating(
            max: 10,
            initialValue: 7,
            size: RatingSize.sm,
            semanticLabel: 'Out of ten',
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Rating(
            initialValue: 3,
            clearable: true,
            semanticLabel: 'Clearable: click the chosen glyph again',
          ),
          Rating(initialValue: 3, disabled: true, semanticLabel: 'Disabled'),
        ],
      ),
    ],
  );
}
