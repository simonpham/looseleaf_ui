import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _tiles = [
  (
    title: 'Visitors',
    value: '12,840',
    note: 'up 12% on last week',
    up: true,
    data: [4, 6, 5, 8, 7, 11, 9, 12, 10, 15, 13, 17],
    variant: SparkVariant.line,
  ),
  (
    title: 'Revenue',
    value: r'$4,320',
    note: 'steady',
    up: true,
    data: [8, 7, 9, 8, 10, 9, 11, 10, 12, 11, 12, 13],
    variant: SparkVariant.area,
  ),
  (
    title: 'Signups',
    value: '318',
    note: 'down 3 since Monday',
    up: false,
    data: [9, 12, 8, 10, 7, 9, 6, 8, 5, 7, 6, 4],
    variant: SparkVariant.bar,
  ),
];

class ChartSparklinesExample extends StatelessWidget {
  const ChartSparklinesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        for (final (index, tile) in _tiles.indexed)
          Expanded(
            child: Card(
              seed: 'spark$index',
              gap: Spacing.d12,
              padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
              children: [
                CardHeader(
                  children: [
                    CardDescription(Text(tile.title)),
                    CardTitle(
                      Text(
                        tile.value,
                        style: theme.typography.title(cssSize: 30),
                      ),
                    ),
                  ],
                ),
                CardContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d12,
                    children: [
                      SizedBox(
                        height: Spacing.d40,
                        child: Sparkline(
                          data: tile.data,
                          variant: tile.variant,
                          label: '${tile.title}, last twelve days',
                          slot: switch (index) {
                            2 => 1,
                            _ => 0,
                          },
                        ),
                      ),
                      Row(
                        spacing: Spacing.d4,
                        children: [
                          InkIcon(
                            switch (tile.up) {
                              true => 'arrow-up',
                              false => 'arrow-down',
                            },
                            size: Spacing.d14,
                            color: switch (tile.up) {
                              true => theme.colors.green,
                              false => theme.colors.red,
                            },
                          ),
                          Flexible(
                            child: Text(
                              tile.note,
                              style: theme.typography.interface(
                                cssSize: 14,
                                color: theme.colors.inkMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
