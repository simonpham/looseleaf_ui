import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerSheetPeelExample extends StatelessWidget {
  const StickerSheetPeelExample({super.key});

  static const _names = [
    'rocket',
    'cloud-smile',
    'sun-shades',
    'ringed-planet',
    'done',
    'rainbow',
    'first-place',
    'number-one',
    'a-plus',
    'hundred',
    'moon-sleepy',
    'sale',
  ];

  @override
  Widget build(BuildContext context) => StickerSheet(
    title: 'Sticker sheet no. 4',
    defaultPeeled: const ['done', 'hundred'],
    children: [for (final name in _names) StickerSheetItem(name: name)],
  );
}
