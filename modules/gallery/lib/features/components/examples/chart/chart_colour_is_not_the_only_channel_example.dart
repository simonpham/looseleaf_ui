import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = <ChartRow>[
  {'quarter': 'Q1', 'north': 120, 'south': 90, 'east': 60, 'west': 40},
  {'quarter': 'Q2', 'north': 150, 'south': 70, 'east': 80, 'west': 55},
  {'quarter': 'Q3', 'north': 110, 'south': 100, 'east': 95, 'west': 30},
  {'quarter': 'Q4', 'north': 180, 'south': 120, 'east': 70, 'west': 65},
];

const _config = {
  'north': ChartSeriesConfig(label: 'North'),
  'south': ChartSeriesConfig(label: 'South'),
  'east': ChartSeriesConfig(label: 'East'),
  'west': ChartSeriesConfig(label: 'West'),
};

/// CSS `grayscale(1)`.
const _grayscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

const _color = ColorFilter.matrix([
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0,
]);

class ChartColourIsNotTheOnlyChannelExample extends StatefulWidget {
  const ChartColourIsNotTheOnlyChannelExample({super.key});

  @override
  State<ChartColourIsNotTheOnlyChannelExample> createState() =>
      _ChartColourIsNotTheOnlyChannelExampleState();
}

class _ChartColourIsNotTheOnlyChannelExampleState
    extends State<ChartColourIsNotTheOnlyChannelExample> {
  bool _grey = true;
  bool _patterns = true;

  ButtonVariant _variant(bool on) => switch (on) {
    true => ButtonVariant.primary,
    false => ButtonVariant.outline,
  };

  @override
  Widget build(BuildContext context) {
    final patterns = switch (_patterns) {
      true => ChartPatterns.auto,
      false => ChartPatterns.off,
    };
    final charts = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        Expanded(
          child: ChartContainer(
            config: _config,
            patterns: patterns,
            height: Spacing.d256,
            children: const [
              BarChart(
                data: _rows,
                xKey: 'quarter',
                label: 'Sales by region, bars',
                showValues: false,
              ),
              ChartTooltip(),
              ChartLegend(),
            ],
          ),
        ),
        Expanded(
          child: ChartContainer(
            config: _config,
            patterns: patterns,
            height: Spacing.d256,
            children: const [
              LineChart(
                data: _rows,
                xKey: 'quarter',
                label: 'Sales by region, lines',
                dots: true,
              ),
              ChartTooltip(),
              ChartLegend(),
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Wrap(
          spacing: Spacing.d8,
          runSpacing: Spacing.d8,
          children: [
            Button(
              size: ButtonSize.sm,
              variant: _variant(_grey),
              onPressed: () => setState(() => _grey = !_grey),
              child: const Text('grayscale'),
            ),
            Button(
              size: ButtonSize.sm,
              variant: _variant(_patterns),
              onPressed: () => setState(() => _patterns = !_patterns),
              child: const Text('patterns'),
            ),
          ],
        ),
        ColorFiltered(
          colorFilter: switch (_grey) {
            true => _grayscale,
            false => _color,
          },
          child: charts,
        ),
      ],
    );
  }
}
