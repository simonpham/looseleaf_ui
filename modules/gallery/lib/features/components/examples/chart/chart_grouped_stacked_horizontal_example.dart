import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = <ChartRow>[
  {'quarter': 'Q1', 'income': 120, 'costs': -60, 'tax': -12},
  {'quarter': 'Q2', 'income': 150, 'costs': -90, 'tax': -18},
  {'quarter': 'Q3', 'income': 90, 'costs': -40, 'tax': -9},
  {'quarter': 'Q4', 'income': 180, 'costs': -110, 'tax': -22},
];

const _config = {
  'income': ChartSeriesConfig(label: 'Income'),
  'costs': ChartSeriesConfig(label: 'Costs'),
  'tax': ChartSeriesConfig(label: 'Tax'),
};

enum _Mode { grouped, stacked, sideways }

class ChartGroupedStackedHorizontalExample extends StatefulWidget {
  const ChartGroupedStackedHorizontalExample({super.key});

  @override
  State<ChartGroupedStackedHorizontalExample> createState() =>
      _ChartGroupedStackedHorizontalExampleState();
}

class _ChartGroupedStackedHorizontalExampleState
    extends State<ChartGroupedStackedHorizontalExample> {
  _Mode _mode = _Mode.grouped;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      Semantics(
        container: true,
        label: 'Layout',
        child: Wrap(
          spacing: Spacing.d8,
          children: [
            for (final mode in _Mode.values)
              Button(
                size: ButtonSize.sm,
                variant: switch (mode == _mode) {
                  true => ButtonVariant.primary,
                  false => ButtonVariant.outline,
                },
                onPressed: () => setState(() => _mode = mode),
                child: Text(mode.name),
              ),
          ],
        ),
      ),
      ChartContainer(
        config: _config,
        height: Spacing.d288,
        children: [
          BarChart(
            data: _rows,
            xKey: 'quarter',
            stacked: _mode == _Mode.stacked,
            horizontal: _mode == _Mode.sideways,
            label: 'Income, costs and tax by quarter',
          ),
          const ChartTooltip(),
          const ChartLegend(),
        ],
      ),
    ],
  );
}
