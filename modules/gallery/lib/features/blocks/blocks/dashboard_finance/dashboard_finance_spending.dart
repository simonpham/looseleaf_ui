import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Where it went": the month's money out by category in a donut.
class DashboardFinanceSpending extends StatelessWidget {
  const DashboardFinanceSpending({
    super.key,
    required this.list,
    required this.month,
    required this.monthName,
  });

  final List<FinanceTransaction> list;
  final String month;
  final String monthName;

  static String _slug(String category) =>
      category.toLowerCase().replaceAll(RegExp('[^a-z]+'), '-');

  @override
  Widget build(BuildContext context) {
    final spent = financeSpentBy(list, month);
    final used = [
      for (final category in financeCategories)
        if ((spent[category] ?? 0) > 0) category,
    ];
    final data = <ChartRow>[
      for (final category in used)
        {'category': _slug(category), 'cents': spent[category]},
    ];
    final total = used.fold<int>(0, (sum, c) => sum + (spent[c] ?? 0));
    return Card(
      seed: 'finance-spending',
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('Where it went')),
            CardDescription(Text('Money out in $monthName, by category')),
          ],
        ),
        CardContent(
          child: ChartContainer(
            config: {
              for (final category in used)
                _slug(category): ChartSeriesConfig(label: category),
            },
            height: Spacing.d256,
            children: [
              DonutChart(
                data: data,
                nameKey: 'category',
                valueKey: 'cents',
                label: 'Money out in $monthName, by category',
                showLabels: false,
                valueFormatter: financeMoney,
                centerLabel: (_) => ChartCenterLabel(
                  value: financeDollars(total / 100),
                  label: 'spent',
                ),
              ),
              const ChartTooltip(),
              const ChartLegend(),
            ],
          ),
        ),
      ],
    );
  }
}
