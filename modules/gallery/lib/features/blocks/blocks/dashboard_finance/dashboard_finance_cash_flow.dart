import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "In and out": money in against money out per month, with the slow
/// month noted.
class DashboardFinanceCashFlow extends StatelessWidget {
  const DashboardFinanceCashFlow({super.key, required this.list});

  final List<FinanceTransaction> list;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      seed: 'finance-flow',
      children: [
        const CardHeader(
          children: [
            CardTitle(Text('In and out')),
            CardDescription(
              Text('Money in against money out, April to September'),
            ),
          ],
        ),
        CardContent(
          child: ChartContainer(
            config: {
              'income': ChartSeriesConfig(
                label: 'Money in',
                color: theme.colors.green,
              ),
              'spending': ChartSeriesConfig(
                label: 'Money out',
                color: theme.colors.marker,
              ),
            },
            height: Spacing.d256,
            children: [
              BarChart(
                data: financeCashFlow(list),
                xKey: 'month',
                label: 'Money in and money out per month, April to September',
                yFormatter: financeDollars,
                valueFormatter: financeDollars,
                annotations: const [
                  ChartAnnotation(
                    at: 'min',
                    series: 'income',
                    text: 'a slow month',
                  ),
                ],
              ),
              const ChartTooltip(content: ChartTooltipContent()),
              const ChartLegend(),
            ],
          ),
        ),
      ],
    );
  }
}
