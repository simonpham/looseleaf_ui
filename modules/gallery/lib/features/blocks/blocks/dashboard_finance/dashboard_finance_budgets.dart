import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Budgets": a pencil bar per pot, turning to a red line when a pot is
/// overspent.
class DashboardFinanceBudgets extends StatelessWidget {
  const DashboardFinanceBudgets({
    super.key,
    required this.spent,
    required this.monthName,
  });

  /// Money out per category, in cents.
  final Map<String, int> spent;
  final String monthName;

  static ProgressTone _tone(int used, int budget) {
    if (used > budget) return ProgressTone.marker;
    if (used / budget >= 0.85) return ProgressTone.hi;
    return ProgressTone.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return Card(
      seed: 'finance-budgets',
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('Budgets')),
            CardDescription(Text('What each pot has left in $monthName')),
          ],
        ),
        CardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d20,
            children: [
              for (final (index, budget) in financeBudgets.indexed)
                _pot(theme, small, index, budget),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pot(
    LooseleafThemeData theme,
    TextStyle small,
    int index,
    ({String category, int cents}) budget,
  ) {
    final used = spent[budget.category] ?? 0;
    final left = budget.cents - used;
    final over = left < 0;
    final red = theme.colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d6,
      children: [
        Wrap(
          spacing: Spacing.d12,
          runSpacing: Spacing.d4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [
                InkIcon(financeCategoryIcon[budget.category] ?? 'wallet'),
                Text(
                  budget.category,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(
              '${financeMoney(used)} of ${financeMoney(budget.cents)}',
              style: small,
            ),
          ],
        ),
        Progress(
          value: (used / budget.cents * 100).clamp(0, 100).toDouble(),
          tone: _tone(used, budget.cents),
          seed: 'finance-budget-$index',
          semanticLabel:
              '${budget.category}: ${financeMoney(used)} spent of ${financeMoney(budget.cents)}',
        ),
        switch (over) {
          true => Row(
            spacing: Spacing.d6,
            children: [
              InkIcon('triangle-alert', size: Spacing.d14, color: red),
              Text(
                'Over by ${financeMoney(-left)}',
                style: small.copyWith(color: red, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          false => Text(switch (left) {
            0 => 'All of it spent, exactly',
            _ => '${financeMoney(left)} left',
          }, style: small),
        },
      ],
    );
  }
}
