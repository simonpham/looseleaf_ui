import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _ranges = {'90d': 91, '30d': 30, '7d': 7};

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

class ChartAreaInteractiveExample extends StatefulWidget {
  const ChartAreaInteractiveExample({super.key});

  @override
  State<ChartAreaInteractiveExample> createState() =>
      _ChartAreaInteractiveExampleState();
}

class _ChartAreaInteractiveExampleState
    extends State<ChartAreaInteractiveExample> {
  String _range = '90d';

  @override
  Widget build(BuildContext context) {
    final days = _ranges[_range] ?? daily.length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d448),
        child: Card(
          fastener: FastenerKind.pin,
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Area Chart - Interactive')),
                const CardDescription(
                  Text('Showing total visitors for the last 3 months'),
                ),
                CardAction(
                  child: SizedBox(
                    width: Spacing.d176,
                    child: Select(
                      value: _range,
                      onChanged: (value) => setState(() => _range = value),
                      content: const SelectContent(
                        position: SelectPosition.popper,
                        align: OverlayAlign.end,
                        children: [
                          SelectItem(
                            value: '90d',
                            child: Text('Last 3 months'),
                          ),
                          SelectItem(value: '30d', child: Text('Last 30 days')),
                          SelectItem(value: '7d', child: Text('Last 7 days')),
                        ],
                      ),
                      child: const SelectTrigger(
                        size: SelectSize.sm,
                        semanticLabel: 'Time range',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CardContent(
              child: ChartContainer(
                config: _config,
                height: Spacing.d256,
                children: [
                  AreaChart(
                    data: daily.sublist(daily.length - days),
                    xKey: 'date',
                    xFormatter: dayLabel,
                    series: const ['mobile', 'desktop'],
                    stacked: true,
                    label: 'Visitors per day',
                  ),
                  const ChartTooltip(
                    content: ChartTooltipContent(labelFormatter: dayOfRow),
                  ),
                  const ChartLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
