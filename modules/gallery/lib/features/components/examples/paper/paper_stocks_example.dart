import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperStocksExample extends StatelessWidget {
  const PaperStocksExample({super.key});

  static const _wide = 672.0;
  static const _stocks = [
    StockName.paper,
    StockName.slip,
    StockName.indexCard,
    StockName.graph,
    StockName.dotGrid,
    StockName.kraft,
    StockName.stickyYellow,
    StockName.stickyPink,
  ];

  @override
  Widget build(BuildContext context) {
    final caption = LooseleafTheme.of(context).typography.face(
      KevinSansFace.script,
      cssSize: 20,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth >= _wide) {
          true => 4,
          false => 2,
        };
        final width =
            (constraints.maxWidth - Spacing.d4 - Spacing.d32 * (columns - 1)) /
            columns;
        return Padding(
          padding: const EdgeInsets.all(Spacing.d8),
          child: Wrap(
            spacing: Spacing.d32,
            runSpacing: Spacing.d32,
            children: [
              for (final stock in _stocks)
                SizedBox(
                  width: width - Spacing.d12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      Paper(
                        stock: stock,
                        seed: stock.id,
                        child: const SizedBox(height: Spacing.d96),
                      ),
                      Text(stock.id, style: caption),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
