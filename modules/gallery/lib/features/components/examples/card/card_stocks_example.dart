import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Below this width the cards stack (`sm:grid-cols-2`).
const _twoColumns = 400.0;

const _cards = [
  (
    stock: StockName.graph,
    rules: RuleName.graph,
    title: 'Graph',
    edge: EdgeSpec.all(EdgeKind.cut),
  ),
  (
    stock: StockName.dotGrid,
    rules: RuleName.dots,
    title: 'Dot grid',
    edge: EdgeSpec.all(EdgeKind.cut),
  ),
  (
    stock: StockName.kraft,
    rules: RuleName.none,
    title: 'Kraft',
    edge: EdgeSpec.all(EdgeKind.cut),
  ),
  (
    stock: StockName.indexCard,
    rules: RuleName.none,
    title: 'Torn index card',
    edge: EdgeSpec(top: EdgeKind.torn),
  ),
];

class CardStocksExample extends StatelessWidget {
  const CardStocksExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.d8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = switch (constraints.maxWidth < _twoColumns) {
            true => 1,
            false => 2,
          };
          final cellWidth =
              (constraints.maxWidth - Spacing.d28 * (columns - 1)) / columns;
          return Wrap(
            spacing: Spacing.d28,
            runSpacing: Spacing.d28,
            children: [
              for (final card in _cards)
                SizedBox(
                  width: cellWidth,
                  child: Card(
                    stock: card.stock,
                    rules: card.rules,
                    edge: card.edge,
                    seed: card.title,
                    gap: Spacing.d8,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.d20),
                    children: [
                      CardHeader(
                        children: [
                          CardTitle(Text(card.title)),
                          CardDescription(Text(card.stock.id)),
                        ],
                      ),
                      CardContent(
                        child: Text(
                          'pencil, ink and a little tea',
                          style: theme.typography.interface(cssSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
