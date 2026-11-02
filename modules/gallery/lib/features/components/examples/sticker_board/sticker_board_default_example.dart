import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerBoardDefaultExample extends StatelessWidget {
  const StickerBoardDefaultExample({super.key});

  static const _start = [
    StickerBoardItem(
      id: 'planet',
      name: 'ringed-planet',
      x: 130,
      y: 130,
      rot: -8,
      scale: 1.2,
      z: 0,
    ),
    StickerBoardItem(
      id: 'rocket',
      name: 'rocket',
      x: 290,
      y: 100,
      rot: 24,
      scale: 1,
      z: 1,
    ),
    StickerBoardItem(
      id: 'cloud',
      name: 'cloud-smile',
      x: 432,
      y: 150,
      rot: -3,
      scale: 1.1,
      z: 2,
    ),
    StickerBoardItem(
      id: 'sun',
      name: 'sun-shades',
      x: 310,
      y: 262,
      rot: 10,
      scale: 1.25,
      z: 3,
    ),
    StickerBoardItem(
      id: 'done',
      name: 'done',
      x: 130,
      y: 290,
      rot: 6,
      scale: 0.9,
      z: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) => const StickerBoard(
    defaultValue: _start,
    children: [
      StickerBoardCanvas(height: Spacing.d384 + Spacing.d32),
      StickerBoardToolbar(),
    ],
  );
}
