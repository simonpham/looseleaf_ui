import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PeelCornerDefaultExample extends StatelessWidget {
  const PeelCornerDefaultExample({super.key});

  static const _width = Spacing.d320;
  static const _height = 208.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final big = theme.typography.face(
      KevinSansFace.script,
      cssSize: 36,
      cssLineHeight: 1,
    );
    final small = theme.typography.interface(cssSize: 14);
    return SizedBox(
      width: _width,
      child: PeelCorner(
        children: [
          PeelCornerPage(
            height: _height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spring sale', style: big),
                const SizedBox(height: Spacing.d8),
                Text('Everything in the shop, one week only.', style: small),
                const SizedBox(height: Spacing.d4),
                Text(
                  'Peek under the corner for a code.',
                  style: small.copyWith(color: theme.colors.pencilText),
                ),
              ],
            ),
          ),
          PeelCornerUnder(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('SAVE10', style: big),
                Text(
                  'ten off your next order',
                  style: small.copyWith(color: theme.colors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
