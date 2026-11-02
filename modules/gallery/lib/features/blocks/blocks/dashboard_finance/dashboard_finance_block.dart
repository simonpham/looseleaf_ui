import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A household ledger on a punched sheet: balances on a receipt, money in
/// and out, budgets, where the money went, a heads-up note and the month's
/// transactions.
///
/// Mirrors upstream `src/blocks/dashboard-finance/page.tsx`.
class DashboardFinanceBlock extends StatefulWidget {
  const DashboardFinanceBlock({super.key});

  @override
  State<DashboardFinanceBlock> createState() => _DashboardFinanceBlockState();
}

class _DashboardFinanceBlockState extends State<DashboardFinanceBlock> {
  List<FinanceTransaction> _all = financeTransactions;
  String _monthId = financeMonths.first.id;

  static const double _balancesWidth = 288;
  static const double _sideWidth = 352;
  static const double _selectWidth = 192;

  void _add(FinanceTransaction transaction) {
    final next = _all.fold(
      0,
      (most, t) => switch (t.id > most) {
        true => t.id,
        false => most,
      },
    );
    setState(
      () => _all = [
        (
          id: next + 1,
          date: transaction.date,
          description: transaction.description,
          account: transaction.account,
          category: transaction.category,
          cents: transaction.cents,
          status: transaction.status,
        ),
        ..._all,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => _sheet(context, constraints.maxWidth),
  );

  Widget _sheet(BuildContext context, double width) {
    final theme = LooseleafTheme.of(context);
    final month = financeMonths.firstWhere(
      (m) => m.id == _monthId,
      orElse: () => financeMonths.first,
    );
    final list = financeInMonth(_all, month.id);
    final spent = financeSpentBy(_all, month.id);
    final addDate = switch (month.id == financeToday.substring(0, 7)) {
      true => financeToday,
      false => '${month.id}-28',
    };
    final large = width >= 1024;
    Widget pair(Widget first, Widget second, {required bool fixedFirst}) {
      if (!large) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [first, second],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: switch (fixedFirst) {
          true => [
            SizedBox(width: _balancesWidth, child: first),
            Expanded(child: second),
          ],
          false => [
            Expanded(child: first),
            SizedBox(width: _sideWidth, child: second),
          ],
        },
      );
    }

    return PaperPage(
      width: PageWidth.full,
      holes: PageHoles.start,
      reinforced: true,
      tilt: false,
      rules: RuleName.none,
      seed: 'dashboard-finance',
      children: [
        switch (width >= 640) {
          true => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Spacing.d24,
            children: [
              Expanded(
                child: PageHeader(
                  children: [
                    Text(
                      'Household ledger',
                      style: theme.typography
                          .stamp(cssSize: 14, color: theme.colors.inkMuted)
                          .copyWith(letterSpacing: 0.35),
                    ),
                    PageTitle(
                      Text(month.name),
                      underline: TitleMark.double,
                      seed: 'finance-title',
                    ),
                    const PageDescription(
                      Text(
                        'Money in, money out, and what is left in each pot.',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _selectWidth,
                child: Select(
                  value: _monthId,
                  onChanged: (id) => setState(() => _monthId = id),
                  content: SelectContent(
                    children: [
                      for (final m in financeMonths)
                        SelectItem(value: m.id, child: Text(m.label)),
                    ],
                  ),
                  child: const SelectTrigger(semanticLabel: 'Month'),
                ),
              ),
            ],
          ),
          false => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              PageHeader(
                children: [
                  Text(
                    'Household ledger',
                    style: theme.typography
                        .stamp(cssSize: 14, color: theme.colors.inkMuted)
                        .copyWith(letterSpacing: 0.35),
                  ),
                  PageTitle(
                    Text(month.name),
                    underline: TitleMark.double,
                    seed: 'finance-title',
                  ),
                  const PageDescription(
                    Text('Money in, money out, and what is left in each pot.'),
                  ),
                ],
              ),
              SizedBox(
                width: _selectWidth,
                child: Select(
                  value: _monthId,
                  onChanged: (id) => setState(() => _monthId = id),
                  content: SelectContent(
                    children: [
                      for (final m in financeMonths)
                        SelectItem(value: m.id, child: Text(m.label)),
                    ],
                  ),
                  child: const SelectTrigger(semanticLabel: 'Month'),
                ),
              ),
            ],
          ),
        },
        pair(
          const DashboardFinanceBalances(),
          DashboardFinanceCashFlow(list: _all),
          fixedFirst: true,
        ),
        pair(
          DashboardFinanceBudgets(spent: spent, monthName: month.name),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d24,
            children: [
              DashboardFinanceSpending(
                list: _all,
                month: month.id,
                monthName: month.name,
              ),
              DashboardFinanceHeadsUp(spent: spent),
            ],
          ),
          fixedFirst: false,
        ),
        DashboardFinanceTransactions(
          list: list,
          monthName: month.name,
          addDate: addDate,
          onAdd: _add,
          width: width,
        ),
      ],
    );
  }
}
