import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A pinned sticky note listing the pots that are over, spent or nearly
/// spent.
class DashboardFinanceHeadsUp extends StatelessWidget {
  const DashboardFinanceHeadsUp({super.key, required this.spent});

  /// Money out per category, in cents.
  final Map<String, int> spent;

  static const double _width = 256;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final lines = [
      for (final budget in financeBudgets)
        ?_line(budget.category, spent[budget.category] ?? 0, budget.cents),
    ];
    final style = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 18.4,
      cssLineHeight: 1.25,
    );
    return Center(
      child: Semantics(
        container: true,
        label: 'Heads up',
        child: StickyNote(
          fastener: FastenerKind.pin,
          seed: 'finance-headsup',
          width: _width,
          minHeight: Spacing.d40,
          children: [
            const StickyNoteTitle(Text('Heads up')),
            StickyNoteContent(
              switch (lines) {
                [] => Text('Every pot has room this month.', style: style),
                _ => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in lines) Text(line, style: style),
                  ],
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  static String? _line(String category, int used, int budget) {
    if (used > budget) {
      return '$category is ${financeMoney(used - budget)} over.';
    }
    if (used == budget) return '$category is all spent.';
    if (used / budget >= 0.85) {
      return '$category: ${financeMoney(budget - used)} to go.';
    }
    return null;
  }
}
