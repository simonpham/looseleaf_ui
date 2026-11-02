import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerDefaultExample extends StatelessWidget {
  const StickerDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d24,
    runSpacing: Spacing.d24,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final name in const [
        'done',
        'sale',
        'cursor-click',
        'hand-point-right',
      ])
        Sticker(name),
    ],
  );
}
