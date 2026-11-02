import 'package:flutter/widgets.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "By the numbers": the counts on taped graph paper, each with a tally.
///
/// Mirrors `Stats` in upstream `src/docs/content/home/stats.tsx`.
class HomeStats extends StatelessWidget {
  const HomeStats({
    super.key,
    required this.componentCount,
    required this.categoryCount,
  });

  final int componentCount;
  final int categoryCount;

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatEntry(
        value: '$componentCount',
        label: 'components',
        strokes: componentCount ~/ 10,
        per: 'one stroke is ten',
      ),
      const StatEntry(
        value: '300+',
        label: 'drawn things: icons, stickers, doodles, Stubby',
        strokes: 30,
        per: 'one stroke is ten',
      ),
      StatEntry(
        value: '$categoryCount',
        label: 'categories, from buttons to charts',
        strokes: categoryCount,
        per: 'one stroke each',
      ),
      const StatEntry(
        value: '1,200+',
        label: 'tests, with goldens and parity checks against the original',
        strokes: 12,
        per: 'one stroke is a hundred',
      ),
    ];
    return DeskSection(
      title: 'By the numbers',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomy = constraints.maxWidth >= DeskSection.roomyFrom;
          final twoColumns = constraints.maxWidth >= LiveCardRow.twoColumnsFrom;
          return Paper(
            stock: StockName.graph,
            tape: PaperTape.top,
            seed: 'home-stats',
            padding: EdgeInsets.fromLTRB(
              switch (roomy) {
                true => Spacing.d40,
                false => Spacing.d24,
              },
              Spacing.d36,
              switch (roomy) {
                true => Spacing.d40,
                false => Spacing.d24,
              },
              Spacing.d32,
            ),
            child: switch (twoColumns) {
              false => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d36,
                children: stats,
              ),
              true => Column(
                spacing: Spacing.d36,
                children: [
                  for (var start = 0; start < stats.length; start += 2)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d40,
                      children: [
                        for (final stat in stats.skip(start).take(2))
                          Expanded(child: stat),
                      ],
                    ),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}
