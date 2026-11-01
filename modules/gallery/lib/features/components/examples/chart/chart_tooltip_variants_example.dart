import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = <ChartRow>[
  {'month': 'January', 'desktop': 186, 'mobile': 80},
  {'month': 'February', 'desktop': 305, 'mobile': 200},
  {'month': 'March', 'desktop': 237, 'mobile': 120},
  {'month': 'April', 'desktop': 73, 'mobile': 190},
];

const _config = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

String _short(Object? month, int index) => '$month'.substring(0, 3);

class ChartTooltipVariantsExample extends StatelessWidget {
  const ChartTooltipVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        Expanded(
          child: ChartContainer(
            config: _config,
            height: Spacing.d112 * 2,
            children: [
              const BarChart(
                data: _rows,
                xKey: 'month',
                xFormatter: _short,
                label: 'Indicator: line',
              ),
              ChartTooltip(
                content: ChartTooltipContent(
                  indicator: ChartTooltipIndicator.line,
                  labelFormatter: (label, _) => Text('In $label'),
                ),
                defaultIndex: 1,
              ),
            ],
          ),
        ),
        Expanded(
          child: ChartContainer(
            config: _config,
            height: Spacing.d112 * 2,
            children: [
              const BarChart(
                data: _rows,
                xKey: 'month',
                xFormatter: _short,
                label: 'Formatter',
              ),
              ChartTooltip(
                content: ChartTooltipContent(
                  hideIndicator: true,
                  formatter: (value, name, _, _, _) => Row(
                    spacing: Spacing.d16,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(color: theme.colors.inkMuted),
                        ),
                      ),
                      Text(
                        '$value visits',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 18,
                          cssLineHeight: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                defaultIndex: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
