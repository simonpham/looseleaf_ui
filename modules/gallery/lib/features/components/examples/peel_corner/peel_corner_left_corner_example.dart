import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PeelCornerLeftCornerExample extends StatelessWidget {
  const PeelCornerLeftCornerExample({super.key});

  static const _width = Spacing.d288;
  static const _height = Spacing.d192;
  static const _peel = 100.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: _width,
      child: PeelCorner(
        corner: PeelCornerSide.bottomLeft,
        back: PaintKey.kraft,
        size: _peel,
        children: [
          PeelCornerPage(
            height: _height,
            stock: StockName.kraft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Text(
                  'Field notes',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 30,
                    cssLineHeight: 1,
                  ),
                ),
                Text(
                  'Volume 4. Do not read the last page.',
                  style: theme.typography.interface(cssSize: 14),
                ),
              ],
            ),
          ),
          PeelCornerUnder(
            stock: StockName.indexCard,
            child: Text(
              'P.S. I told you.',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
