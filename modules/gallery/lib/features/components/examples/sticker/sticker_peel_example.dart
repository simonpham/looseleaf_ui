import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerPeelExample extends StatelessWidget {
  const StickerPeelExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Sticker('done', peel: Peel.auto()),
      Sticker('sale', peel: Peel(22)),
      Sticker('cursor-click', peel: Peel.auto(), rotate: -5),
      Sticker('hand-point-right', peel: Peel(16), rotate: 4),
    ],
  );
}
