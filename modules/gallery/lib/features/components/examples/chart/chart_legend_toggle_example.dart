import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = <ChartRow>[
  {'month': 'Jan', 'desktop': 186, 'mobile': 80, 'tablet': 40},
  {'month': 'Feb', 'desktop': 305, 'mobile': 200, 'tablet': 66},
  {'month': 'Mar', 'desktop': 237, 'mobile': 120, 'tablet': 90},
  {'month': 'Apr', 'desktop': 73, 'mobile': 190, 'tablet': 84},
  {'month': 'May', 'desktop': 209, 'mobile': 130, 'tablet': 72},
  {'month': 'Jun', 'desktop': 214, 'mobile': 140, 'tablet': 110},
];

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
  'tablet': ChartSeriesConfig(label: 'Tablet'),
};

class ChartLegendToggleExample extends StatefulWidget {
  const ChartLegendToggleExample({super.key});

  @override
  State<ChartLegendToggleExample> createState() =>
      _ChartLegendToggleExampleState();
}

class _ChartLegendToggleExampleState extends State<ChartLegendToggleExample> {
  List<String> _hidden = ['tablet'];

  void _show(List<String> hidden) => setState(() => _hidden = hidden);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      Wrap(
        spacing: Spacing.d8,
        runSpacing: Spacing.d8,
        children: [
          Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () => _show([]),
            child: const Text('all'),
          ),
          Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () => _show(['desktop', 'tablet']),
            child: const Text('only mobile'),
          ),
          Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () => _show(['mobile', 'tablet']),
            child: const Text('only desktop'),
          ),
        ],
      ),
      ChartContainer(
        config: _config,
        hiddenSeries: _hidden,
        onHiddenSeriesChange: _show,
        height: Spacing.d256,
        children: const [
          LineChart(data: _rows, xKey: 'month', label: 'Visitors by device'),
          ChartTooltip(),
          ChartLegend(),
        ],
      ),
    ],
  );
}
