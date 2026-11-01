import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelTagShapesExample extends StatelessWidget {
  const LabelTagShapesExample({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d24),
    child: Wrap(
      spacing: Spacing.d48,
      runSpacing: Spacing.d64,
      alignment: WrapAlignment.center,
      children: [
        LabelTag(
          stock: StockName.paper,
          twine: Accent.tomato,
          eyelet: TagEyelet.steel,
          seed: 'a',
          tiltDegrees: 2,
          children: [
            LabelTagTitle(Text('Gift')),
            LabelTagDescription(Text('for Ada')),
          ],
        ),
        LabelTag(
          stock: StockName.stickyYellow,
          shape: TagShape.round,
          twine: Accent.grass,
          seed: 'b',
          tiltDegrees: -2,
          children: [
            LabelTagTitle(Text('New')),
            LabelTagDescription(Text('this week')),
            LabelTagPrice(Text('4.50')),
          ],
        ),
        LabelTag(
          stock: StockName.stickyPink,
          twine: Accent.grape,
          eyelet: TagEyelet.none,
          seed: 'c',
          tiltDegrees: 3,
          children: [
            LabelTagTitle(Text('Hi!')),
            LabelTagDescription(Text('a bare hole')),
          ],
        ),
        LabelTag(
          shape: TagShape.luggage,
          string: 60,
          seed: 'd',
          tiltDegrees: 1.4,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LabelTagTitle(Text('Ada Lovelace')),
                LabelTagDescription(Text('Gate 7 - seat 14A')),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
