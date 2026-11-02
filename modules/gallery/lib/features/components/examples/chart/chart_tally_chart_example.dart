import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _cups = <ChartRow>[
  {'drink': 'Tea', 'cups': 23},
  {'drink': 'Coffee', 'cups': 14},
  {'drink': 'Cocoa', 'cups': 8},
  {'drink': 'Water', 'cups': 31},
];

class ChartTallyChartExample extends StatelessWidget {
  const ChartTallyChartExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d512),
      child: const ChartContainer(
        config: {},
        aspectRatio: 16 / 8,
        children: [
          TallyChart(
            data: _cups,
            nameKey: 'drink',
            valueKey: 'cups',
            label: 'Cups drunk today',
          ),
          ChartTooltip(),
        ],
      ),
    ),
  );
}
