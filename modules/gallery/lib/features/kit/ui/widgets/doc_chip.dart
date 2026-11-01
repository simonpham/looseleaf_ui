import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// How a [DocChip] is drawn, upstream `ChipTone`.
enum DocChipTone { neutral, stable, fresh, experimental, count, outline }

/// A small badge on a docs page, upstream `Chip` (`src/docs/kit/Chip.tsx`).
class DocChip extends StatelessWidget {
  const DocChip(this.text, {super.key, this.tone = DocChipTone.neutral});

  final String text;
  final DocChipTone tone;

  @override
  Widget build(BuildContext context) => Badge(
    variant: switch (tone) {
      DocChipTone.outline || DocChipTone.count => BadgeVariant.outline,
      DocChipTone.neutral => BadgeVariant.secondary,
      _ => BadgeVariant.primary,
    },
    tone: switch (tone) {
      DocChipTone.stable => BadgeTone.grass,
      DocChipTone.experimental => BadgeTone.bubblegum,
      _ => null,
    },
    size: switch (tone) {
      DocChipTone.count => BadgeSize.sm,
      _ => BadgeSize.regular,
    },
    seed: 'chip:$text',
    child: Text(text),
  );
}
