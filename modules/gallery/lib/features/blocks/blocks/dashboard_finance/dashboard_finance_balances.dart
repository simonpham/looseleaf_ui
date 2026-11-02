import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Every account's balance written up as a clipped till receipt, with the
/// net worth circled.
class DashboardFinanceBalances extends StatelessWidget {
  const DashboardFinanceBalances({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final total = financeAccounts.fold<int>(0, (sum, a) => sum + a.cents);
    return Center(
      child: Receipt(
        fastener: FastenerKind.clip,
        seed: 'finance-balances',
        children: [
          ReceiptHeader(
            children: [
              Semantics(header: true, child: const Text('Balances')),
              const Text('Marigold household'),
              Text('${financeShortDate(financeToday)}, 2026'),
            ],
          ),
          ReceiptLines(
            children: [
              for (final account in financeAccounts)
                ReceiptLine(
                  price: Text(
                    financeMoney(account.cents),
                    style: switch (account.cents < 0) {
                      true => TextStyle(color: theme.colors.red),
                      false => null,
                    },
                  ),
                  child: Text(account.name),
                ),
            ],
          ),
          ReceiptTotal(
            label: const Text('Net worth'),
            circled: ReceiptPen.redfelt,
            seed: 'finance-total',
            child: Text(financeMoney(total)),
          ),
          const ReceiptBarcode(value: '0042 1187 0925'),
          const ReceiptFooter(
            Text('Checked this morning. Thank you, come again.'),
          ),
        ],
      ),
    );
  }
}
