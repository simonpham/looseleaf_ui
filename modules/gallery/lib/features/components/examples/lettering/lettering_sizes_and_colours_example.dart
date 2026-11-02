import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LetteringSizesAndColoursExample extends StatelessWidget {
  const LetteringSizesAndColoursExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d8,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Lettering('small', size: LetteringSize.sm, header: false),
          Lettering('medium', size: LetteringSize.md, header: false),
          Lettering('large', size: LetteringSize.lg, header: false),
        ],
      ),
      Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d8,
        children: [
          Lettering(
            'teal',
            size: LetteringSize.md,
            tone: LetteringTone.teal,
            header: false,
          ),
          Lettering(
            'grape',
            size: LetteringSize.md,
            tone: LetteringTone.grape,
            header: false,
          ),
          Lettering(
            'bubblegum',
            size: LetteringSize.md,
            tone: LetteringTone.bubblegum,
            header: false,
          ),
          Lettering(
            'grass',
            size: LetteringSize.md,
            tone: LetteringTone.grass,
            header: false,
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d40,
        runSpacing: Spacing.d8,
        children: [
          Lettering('Two colors', duotone: LetteringTone.sky, header: false),
          Lettering(
            'hand cut words',
            tone: LetteringTone.teal,
            wobble: 1.6,
            header: false,
          ),
        ],
      ),
    ],
  );
}
