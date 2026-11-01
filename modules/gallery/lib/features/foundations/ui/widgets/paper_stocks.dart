import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A small sheet of every paper stock, named in its own hand.
class PaperStocks extends StatelessWidget {
  const PaperStocks({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return TileGrid(
      minTileWidth: 150,
      spacing: Spacing.d24,
      runSpacing: Spacing.d28,
      children: [
        for (final stock in StockName.values)
          Paper(
            stock: stock,
            seed: 'stock:${stock.id}',
            child: SizedBox(
              height: Spacing.d96,
              width: double.infinity,
              child: Center(
                child: Text(
                  stock.id,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colors.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
