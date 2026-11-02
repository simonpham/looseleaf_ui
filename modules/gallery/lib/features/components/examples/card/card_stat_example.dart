import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Below this width the cards stack (`sm:grid-cols-3`).
const _threeColumns = 480.0;

class CardStatExample extends StatelessWidget {
  const CardStatExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final stats = [
      (
        label: 'Pages written',
        value: '1,284',
        trend: 'up 12% on last week',
        stock: StockName.indexCard,
        color: theme.colors.green,
      ),
      (
        label: 'Drafts open',
        value: '17',
        trend: 'down 3 since Monday',
        stock: StockName.indexCard,
        color: theme.colors.red,
      ),
      (
        label: 'Words per day',
        value: '640',
        trend: 'steady',
        stock: StockName.slip,
        color: theme.colors.inkMuted,
      ),
    ];
    final cards = [
      for (final stat in stats)
        Card(
          stock: stat.stock,
          seed: stat.label,
          gap: Spacing.d12,
          padding: const EdgeInsets.symmetric(vertical: Spacing.d20),
          children: [
            CardHeader(
              children: [
                CardDescription(Text(stat.label)),
                CardTitle(
                  Text(
                    stat.value,
                    style: theme.typography
                        .title(cssSize: 36)
                        .copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ),
              ],
            ),
            CardContent(
              child: Text(
                stat.trend,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: stat.color,
                ),
              ),
            ),
          ],
        ),
    ];
    return Padding(
      padding: const EdgeInsets.all(Spacing.d8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _threeColumns) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d24,
              children: cards,
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [for (final card in cards) Expanded(child: card)],
          );
        },
      ),
    );
  }
}
