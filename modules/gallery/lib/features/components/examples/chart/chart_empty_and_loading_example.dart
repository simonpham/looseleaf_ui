import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = <ChartRow>[
  {'day': 'Mon', 'n': 12},
  {'day': 'Tue', 'n': 19},
  {'day': 'Wed', 'n': 8},
  {'day': 'Thu', 'n': 24},
];

const _config = {'n': ChartSeriesConfig(label: 'Orders')};

enum _State { loading, empty, ready }

class ChartEmptyAndLoadingExample extends StatefulWidget {
  const ChartEmptyAndLoadingExample({super.key});

  @override
  State<ChartEmptyAndLoadingExample> createState() =>
      _ChartEmptyAndLoadingExampleState();
}

class _ChartEmptyAndLoadingExampleState
    extends State<ChartEmptyAndLoadingExample> {
  _State _state = _State.loading;

  @override
  Widget build(BuildContext context) {
    final data = switch (_state) {
      _State.empty => const <ChartRow>[],
      _ => _rows,
    };
    final loading = _state == _State.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Semantics(
          container: true,
          label: 'State',
          child: Wrap(
            spacing: Spacing.d8,
            children: [
              for (final state in _State.values)
                Button(
                  size: ButtonSize.sm,
                  variant: switch (state == _state) {
                    true => ButtonVariant.primary,
                    false => ButtonVariant.outline,
                  },
                  onPressed: () => setState(() => _state = state),
                  child: Text(state.name),
                ),
            ],
          ),
        ),
        Row(
          spacing: Spacing.d24,
          children: [
            Expanded(
              child: ChartContainer(
                config: _config,
                height: Spacing.d192,
                children: [
                  BarChart(
                    data: data,
                    xKey: 'day',
                    series: const ['n'],
                    loading: loading,
                    emptyText: 'No orders yet',
                    label: 'Orders',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ChartContainer(
                config: _config,
                height: Spacing.d192,
                children: [
                  LineChart(
                    data: data,
                    xKey: 'day',
                    series: const ['n'],
                    loading: loading,
                    emptyText: 'Nothing to plot',
                    label: 'Orders, as a line',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ChartContainer(
                config: const {},
                height: Spacing.d192,
                children: [
                  DonutChart(
                    data: data,
                    nameKey: 'day',
                    valueKey: 'n',
                    loading: loading,
                    emptyText: 'No data',
                    label: 'Orders by day',
                    showLabels: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
