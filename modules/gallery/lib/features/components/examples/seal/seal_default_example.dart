import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SealDefaultExample extends StatelessWidget {
  const SealDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d24,
    runSpacing: Spacing.d24,
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      Seal(text: 'Best', sub: 'seller', tone: PaintKey.grass),
      Seal(variant: SealVariant.starburst, text: 'New', tone: PaintKey.lemon),
      Seal(
        variant: SealVariant.rosette,
        text: 'Pick',
        tone: PaintKey.tangerine,
        ribbon: PaintKey.sky,
      ),
      Seal(variant: SealVariant.medal, text: 'Top', tone: PaintKey.lemon),
      Seal(
        variant: SealVariant.shield,
        text: 'Pro',
        sub: 'plan',
        tone: PaintKey.teal,
      ),
      Seal(variant: SealVariant.plate, text: 'Gold', tone: PaintKey.lemon),
      Seal(variant: SealVariant.tag, text: 'Sale', tone: PaintKey.tangerine),
    ],
  );
}
