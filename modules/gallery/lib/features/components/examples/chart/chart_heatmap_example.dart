import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

final _pages = <ChartRow>[
  for (var i = 0; i < 180; i++) _page(i),
];

ChartRow _page(int i) {
  final day = DateTime.utc(2026, 1, 1 + i);
  final wave = math.sin(i / 9) + math.sin(i / 3.3) + ((i * 7) % 5) / 2;
  return {
    'date': day.toIso8601String().substring(0, 10),
    'value': switch (wave > 0.6) {
      true => (wave * 2).round(),
      false => 0,
    },
  };
}

const _hours = ['9am', '11am', '1pm', '3pm', '5pm'];
const _week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
final _busy = <ChartRow>[
  for (final (r, day) in _week.indexed)
    for (final (c, hour) in _hours.indexed)
      {'day': day, 'hour': hour, 'orders': ((r + 1) * (c + 2) * 3) % 17},
];

class ChartHeatmapExample extends StatelessWidget {
  const ChartHeatmapExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d32,
    children: [
      ChartContainer(
        config: const {},
        aspectRatio: 53 / 14,
        children: [
          Heatmap(data: _pages, unit: 'pages', label: 'Pages written per day'),
          const ChartTooltip(),
        ],
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
        child: ChartContainer(
          config: const {},
          aspectRatio: 16 / 10,
          children: [
            Heatmap(
              variant: HeatVariant.grid,
              data: _busy,
              rowKey: 'day',
              colKey: 'hour',
              valueKey: 'orders',
              unit: 'orders',
              slot: 0,
              label: 'Orders by hour',
              rows: _week,
              cols: _hours,
              showLegend: false,
            ),
            const ChartTooltip(),
          ],
        ),
      ),
    ],
  );
}
