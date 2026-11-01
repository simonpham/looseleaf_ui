import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerSheetBackingsExample extends StatelessWidget {
  const StickerSheetBackingsExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    alignment: WrapAlignment.center,
    children: [
      StickerSheet(
        title: 'Badges',
        columns: 3,
        size: Spacing.d64,
        stickers: ['wip', 'new', 'beta', 'pro', 'ok', 'wow'],
        defaultPeeled: ['beta'],
      ),
      StickerSheet(
        title: 'Kraft',
        backing: StickerSheetBacking.kraft,
        columns: 3,
        size: Spacing.d64,
        stickers: [
          'rocket',
          'cloud-smile',
          'sun-shades',
          'done',
          'rainbow',
          'sale',
        ],
      ),
      StickerSheet(
        title: 'Plain',
        backing: StickerSheetBacking.paper,
        columns: 2,
        size: Spacing.d80,
        stickers: ['first-place', 'number-one', 'a-plus', 'hundred'],
      ),
    ],
  );
}
