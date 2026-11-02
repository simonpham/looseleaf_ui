import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerSheetToBoardExample extends StatefulWidget {
  const StickerSheetToBoardExample({super.key});

  @override
  State<StickerSheetToBoardExample> createState() =>
      _StickerSheetToBoardExampleState();
}

class _StickerSheetToBoardExampleState
    extends State<StickerSheetToBoardExample> {
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
  ];

  final _board = GlobalKey<StickerBoardState>();
  List<StickerBoardItem> _items = const [];

  void _peel(StickerSheetPeel peel) {
    final at = switch ((peel.dragged, peel.position)) {
      (true, final position?) => _board.currentState?.boardPoint(position),
      _ => null,
    };
    if (peel.dragged && at?.inside != true) return;
    setState(
      () => _items = StickerBoardOps.add(
        _items,
        peel.name,
        x: at?.point.dx,
        y: at?.point.dy,
        canvas: const Size(460, 380),
      ),
    );
  }

  void _stick(StickerSheetPeel peel) => setState(
    () => _items = [
      for (final item in _items)
        if (item.name != peel.name) item,
    ],
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Wrap(
      spacing: Spacing.d24,
      runSpacing: Spacing.d24,
      alignment: WrapAlignment.center,
      children: [
        StickerSheet(
          title: 'Sticker sheet',
          columns: 3,
          size: 68,
          peeled: [for (final item in _items) item.name],
          onPeel: _peel,
          onStick: _stick,
          children: [for (final name in _names) StickerSheetItem(name: name)],
        ),
        SizedBox(
          width: Spacing.d512,
          child: StickerBoard(
            key: _board,
            value: _items,
            onValueChange: (items) => setState(() => _items = items),
            size: 84,
            children: const [
              StickerBoardCanvas(
                height: 420,
                empty: Text('Peel a sticker off the sheet.'),
              ),
              StickerBoardToolbar(
                actions: [
                  StickerBoardAction.turn,
                  StickerBoardAction.size,
                  StickerBoardAction.layer,
                  StickerBoardAction.delete,
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
