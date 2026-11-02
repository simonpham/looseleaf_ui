import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerBoardRewardChartExample extends StatelessWidget {
  const StickerBoardRewardChartExample({super.key});

  static const _earned = [
    StickerBoardItem(
      id: 'a',
      name: 'a-plus',
      x: 96,
      y: 90,
      rot: -6,
      scale: 0.9,
      z: 0,
    ),
    StickerBoardItem(
      id: 'b',
      name: 'hundred',
      x: 236,
      y: 84,
      rot: 8,
      scale: 0.9,
      z: 1,
    ),
    StickerBoardItem(
      id: 'c',
      name: 'first-place',
      x: 376,
      y: 96,
      rot: -4,
      scale: 0.9,
      z: 2,
    ),
    StickerBoardItem(
      id: 'd',
      name: 'rating-five',
      x: 130,
      y: 210,
      rot: 3,
      scale: 0.9,
      z: 3,
    ),
    StickerBoardItem(
      id: 'e',
      name: 'number-one',
      x: 300,
      y: 216,
      rot: -9,
      scale: 0.9,
      z: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d96 * 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          Text(
            "Maya's stickers, week 12",
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 30,
              color: theme.colors.ink,
            ),
          ),
          const StickerBoard(
            readOnly: true,
            value: _earned,
            size: Spacing.d80 + Spacing.d4,
            label: "Maya's earned stickers",
            children: [StickerBoardCanvas(stock: StockName.ledger)],
          ),
        ],
      ),
    );
  }
}
