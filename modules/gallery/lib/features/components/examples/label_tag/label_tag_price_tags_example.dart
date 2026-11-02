import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelTagPriceTagsExample extends StatelessWidget {
  const LabelTagPriceTagsExample({super.key});

  static const _goods = [
    (
      name: 'Felt tips',
      note: 'twelve colors',
      price: '18.00',
      twine: Accent.tomato,
    ),
    (
      name: 'Washi tape',
      note: 'dots, of course',
      price: '3.00',
      twine: Accent.sky,
    ),
    (name: 'Glue stick', note: 'acid free', price: '2.10', twine: Accent.grass),
    (
      name: 'Notebook',
      note: 'spiral, ruled',
      price: '6.40',
      twine: Accent.grape,
    ),
  ];

  static const _pairWidth = 2 * Spacing.d128 + Spacing.d64;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: Card(
        stock: StockName.kraft,
        seed: 'shelf',
        children: [
          const CardHeader(children: [CardTitle(Text('The stationery shelf'))]),
          CardContent(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.d24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _pairWidth),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: Spacing.d64,
                    runSpacing: Spacing.d48,
                    children: [
                      for (final (i, good) in _goods.indexed)
                        LabelTag(
                          twine: good.twine,
                          seed: good.name,
                          tiltDegrees: switch (i.isOdd) {
                            true => 2,
                            false => -2,
                          },
                          stock: switch (i.isOdd) {
                            true => StockName.paper,
                            false => StockName.indexCard,
                          },
                          semanticLabel: '${good.name}, ${good.price}',
                          children: [
                            LabelTagTitle(Text(good.name), cssSize: 22.4),
                            LabelTagDescription(Text(good.note)),
                            LabelTagPrice(Text(good.price)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
