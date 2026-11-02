import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CorkboardStocksExample extends StatelessWidget {
  const CorkboardStocksExample({super.key});

  static const _maxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Corkboard(
        height: 420,
        label: 'Ideas',
        children: [
          const CorkboardNote(
            id: 'list',
            x: 20,
            y: 24,
            stock: StockName.indexCard,
            label: 'Ideas list',
            pinColor: PaintKey.grass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ideas', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('1. a thing that boils'),
                Text('2. a thing that tears'),
              ],
            ),
          ),
          const CorkboardNote(
            id: 'tag',
            x: 270,
            y: 40,
            stock: StockName.kraft,
            rotate: -4,
            pinColor: PaintKey.tomato,
            child: Text('fragile, hand-drawn'),
          ),
          const CorkboardNote(
            id: 'photo',
            x: 24,
            y: 236,
            stock: StockName.photo,
            rotate: 3,
            pinColor: PaintKey.sky,
            child: Text('summer, 1987'),
          ),
          CorkboardNote(
            id: 'sticky',
            x: 270,
            y: 210,
            bare: true,
            rotate: 1.5,
            pinColor: PaintKey.grape,
            label: 'Sticky note',
            child: StickyNote(
              color: StickyColor.orange,
              curl: true,
              tilt: false,
              width: Spacing.d160,
              children: [
                Text(
                  'pick me up: a real StickyNote',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
