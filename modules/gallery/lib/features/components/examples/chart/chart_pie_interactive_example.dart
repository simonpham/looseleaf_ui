import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _config = {
  'january': ChartSeriesConfig(label: 'January'),
  'february': ChartSeriesConfig(label: 'February'),
  'march': ChartSeriesConfig(label: 'March'),
  'april': ChartSeriesConfig(label: 'April'),
  'may': ChartSeriesConfig(label: 'May'),
};

class ChartPieInteractiveExample extends StatefulWidget {
  const ChartPieInteractiveExample({super.key});

  @override
  State<ChartPieInteractiveExample> createState() =>
      _ChartPieInteractiveExampleState();
}

class _ChartPieInteractiveExampleState
    extends State<ChartPieInteractiveExample> {
  String _month = 'january';

  @override
  Widget build(BuildContext context) {
    final index = monthSlices.indexWhere((s) => s['month'] == _month);
    final picked = monthSlices[index];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d448),
        child: Card(
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Pie Chart - Interactive')),
                const CardDescription(
                  Text('January - May 2024, desktop visitors'),
                ),
                CardAction(
                  child: SizedBox(
                    width: Spacing.d128 + Spacing.d16,
                    child: Select(
                      value: _month,
                      onChanged: (value) => setState(() => _month = value),
                      content: SelectContent(
                        position: SelectPosition.popper,
                        align: OverlayAlign.end,
                        children: [
                          for (final slice in monthSlices)
                            SelectItem(
                              value: '${slice['month']}',
                              child: Text(
                                _config['${slice['month']}']?.label ?? '',
                              ),
                            ),
                        ],
                      ),
                      child: const SelectTrigger(
                        size: SelectSize.sm,
                        semanticLabel: 'Month',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CardContent(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Spacing.d256 + Spacing.d24,
                  ),
                  child: ChartContainer(
                    key: ValueKey(_month),
                    config: _config,
                    aspectRatio: 1,
                    children: [
                      DonutChart(
                        data: monthSlices,
                        nameKey: 'month',
                        valueKey: 'desktop',
                        showLabels: false,
                        label: 'Desktop visitors by month',
                        centerLabel: (info) => ChartCenterLabel(
                          value: thousands(
                            info.active?.value ?? picked['desktop'] as num,
                          ),
                          label:
                              info.active?.name ??
                              _config[_month]?.label ??
                              _month,
                        ),
                      ),
                      ChartTooltip(
                        content: const ChartTooltipContent(hideLabel: true),
                        defaultIndex: index,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
