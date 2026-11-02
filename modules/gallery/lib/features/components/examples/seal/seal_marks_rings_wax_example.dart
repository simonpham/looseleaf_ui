import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SealMarksRingsWaxExample extends StatelessWidget {
  const SealMarksRingsWaxExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d24,
    runSpacing: Spacing.d24,
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Seal(mark: SealMark.check, tone: PaintKey.sky),
      Seal(
        variant: SealVariant.rosette,
        mark: SealMark.check,
        tone: PaintKey.grass,
        ribbon: PaintKey.lemon,
      ),
      Seal(
        variant: SealVariant.starburst,
        mark: SealMark.star,
        tone: PaintKey.tangerine,
      ),
      Seal(
        variant: SealVariant.ring,
        text: 'Verified',
        tone: PaintKey.sky,
        ring: 'Official seal',
        size: Spacing.d128,
      ),
      Seal(
        variant: SealVariant.ring,
        mark: SealMark.check,
        tone: PaintKey.grass,
        ring: 'Checked by hand',
        size: Spacing.d128,
      ),
      Seal(variant: SealVariant.wax, text: 'L', tone: PaintKey.red),
      Seal(
        variant: SealVariant.wax,
        mark: SealMark.check,
        tone: PaintKey.grape,
      ),
    ],
  );
}
