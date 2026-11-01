import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Paint chips for [swatches]: a dab of each token with its name.
class SwatchGrid extends StatelessWidget {
  const SwatchGrid({super.key, required this.swatches});

  final List<Swatch> swatches;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return TileGrid(
      minTileWidth: 128,
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      children: [
        for (final swatch in swatches)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d6,
            children: [
              Paper(
                stock: StockName.photo,
                shadow: PaperShadow.hair,
                seed: 'swatch:${swatch.token}',
                padding: const EdgeInsets.all(Spacing.d4),
                child: SizedBox(
                  height: Spacing.d56,
                  width: double.infinity,
                  child: ColoredBox(
                    color:
                        theme.colors.token(swatch.token) ?? theme.colors.paper,
                  ),
                ),
              ),
              Text(swatch.label, style: theme.typography.label()),
              Text(
                '--ll-${swatch.token}',
                style: theme.typography.mono(
                  cssSize: 12,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
