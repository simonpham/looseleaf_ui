import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _sales = <ChartRow>[
  {'day': 'Mon', 'sales': 12},
  {'day': 'Tue', 'sales': 19},
  {'day': 'Wed', 'sales': 8},
  {'day': 'Thu', 'sales': 24},
  {'day': 'Fri', 'sales': 16},
  {'day': 'Sat', 'sales': 21},
  {'day': 'Sun', 'sales': 14},
];

const _config = {'sales': ChartSeriesConfig(label: 'Sales')};

class ChartBarChartExample extends StatelessWidget {
  const ChartBarChartExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d512),
      child: const Card(
        seed: 'bar',
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Sales this week')),
              CardDescription(Text('Units sold, Monday to Sunday')),
            ],
          ),
          CardContent(
            child: ChartContainer(
              config: _config,
              height: Spacing.d256,
              children: [
                BarChart(
                  data: _sales,
                  xKey: 'day',
                  label: 'Units sold per day',
                  annotations: [
                    ChartAnnotation(
                      at: 'max',
                      text: 'best day!',
                      pen: NotePen.blue,
                    ),
                  ],
                ),
                ChartTooltip(content: ChartTooltipContent()),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
