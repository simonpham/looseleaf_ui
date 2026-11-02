import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _keys = ['desktop', 'mobile'];

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

num _total(String key) =>
    daily.fold<num>(0, (sum, day) => sum + (day[key] as num));

class ChartLineInteractiveExample extends StatefulWidget {
  const ChartLineInteractiveExample({super.key});

  @override
  State<ChartLineInteractiveExample> createState() =>
      _ChartLineInteractiveExampleState();
}

class _ChartLineInteractiveExampleState
    extends State<ChartLineInteractiveExample> {
  String _active = 'desktop';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final label = _config[_active]?.label ?? _active;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
        child: Card(
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Line Chart - Interactive')),
                CardDescription(
                  Text('Showing total visitors for the last 3 months'),
                ),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  Row(
                    spacing: Spacing.d8,
                    children: [
                      for (final key in _keys)
                        Expanded(
                          child: Button(
                            size: ButtonSize.lg,
                            variant: switch (key == _active) {
                              true => ButtonVariant.primary,
                              false => ButtonVariant.outline,
                            },
                            onPressed: () => setState(() => _active = key),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              spacing: Spacing.d8,
                              children: [
                                Flexible(
                                  child: Text(
                                    _config[key]?.label ?? key,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.interface(
                                      cssSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  thousands(_total(key)),
                                  style: theme.typography.face(
                                    KevinSansFace.script,
                                    cssSize: 20,
                                    cssLineHeight: 1,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  ChartContainer(
                    config: _config,
                    height: Spacing.d256,
                    children: [
                      LineChart(
                        data: daily,
                        xKey: 'date',
                        xFormatter: dayLabel,
                        series: [_active],
                        dots: false,
                        label: '$label visitors per day',
                      ),
                      const ChartTooltip(
                        content: ChartTooltipContent(labelFormatter: dayOfRow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
