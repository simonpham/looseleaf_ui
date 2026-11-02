import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Transactions": the month's ledger with an in/out filter, a search box,
/// sortable date and amount columns, status chips and an add dialog.
class DashboardFinanceTransactions extends StatefulWidget {
  const DashboardFinanceTransactions({
    super.key,
    required this.list,
    required this.monthName,
    required this.addDate,
    required this.onAdd,
    required this.width,
  });

  final List<FinanceTransaction> list;
  final String monthName;
  final String addDate;
  final ValueChanged<FinanceTransaction> onAdd;

  /// The block's width, standing in for upstream's viewport breakpoints.
  final double width;

  @override
  State<DashboardFinanceTransactions> createState() =>
      _DashboardFinanceTransactionsState();
}

class _DashboardFinanceTransactionsState
    extends State<DashboardFinanceTransactions> {
  final _query = TextEditingController();
  var _show = 'all';
  var _sortKey = 'date';
  var _ascending = false;

  static const double _searchMin = 160;
  static const double _searchMax = 256;

  static const _status = {
    FinanceStatus.cleared: (
      label: 'Cleared',
      variant: BadgeVariant.outline,
      icon: 'circle-check',
    ),
    FinanceStatus.pending: (
      label: 'Pending',
      variant: BadgeVariant.secondary,
      icon: 'clock',
    ),
    FinanceStatus.flagged: (
      label: 'Flagged',
      variant: BadgeVariant.destructive,
      icon: 'triangle-alert',
    ),
  };

  @override
  void initState() {
    super.initState();
    _query.addListener(_changed);
  }

  @override
  void dispose() {
    _query
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  void _sort(String key) => setState(() {
    if (_sortKey == key) {
      _ascending = !_ascending;
      return;
    }
    _sortKey = key;
    _ascending = key != 'date';
  });

  List<FinanceTransaction> _rows() {
    final query = _query.text.trim().toLowerCase();
    final rows = [
      for (final t in widget.list)
        if (switch (_show) {
              'in' => t.cents > 0,
              'out' => t.cents < 0,
              _ => true,
            } &&
            (query.isEmpty ||
                t.description.toLowerCase().contains(query) ||
                t.category.toLowerCase().contains(query)))
          t,
    ];
    final sign = switch (_ascending) {
      true => 1,
      false => -1,
    };
    rows.sort((a, b) {
      if (_sortKey == 'amount') return sign * a.cents.compareTo(b.cents);
      final byDate = a.date.compareTo(b.date);
      return sign *
          switch (byDate) {
            0 => a.id.compareTo(b.id),
            _ => byDate,
          };
    });
    return rows;
  }

  TableSort? _sortOf(String key) => switch ((_sortKey == key, _ascending)) {
    (false, _) => null,
    (true, true) => TableSort.ascending,
    (true, false) => TableSort.descending,
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final width = widget.width;
    final medium = width >= 768;
    final large = width >= 1024;
    final small = width >= 640;
    final rows = _rows();
    final add = DashboardFinanceAddDialog(
      date: widget.addDate,
      onAdd: widget.onAdd,
    );
    final inset = EdgeInsets.symmetric(
      horizontal: switch (small) {
        true => Spacing.d24,
        false => Spacing.d16,
      },
    );
    final description = CardDescription(
      Text('${rows.length} of ${widget.list.length} in ${widget.monthName}'),
    );
    return Card(
      seed: 'finance-transactions',
      children: [
        LayoutBuilder(
          builder: (context, constraints) => CardHeader(
            padding: inset,
            children: [
              const CardTitle(Text('Transactions')),
              description,
              switch (constraints.maxWidth - inset.horizontal >= 448) {
                true => CardAction(child: add),
                false => add,
              },
            ],
          ),
        ),
        CardContent(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d16,
            children: [
              Wrap(
                spacing: Spacing.d12,
                runSpacing: Spacing.d12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ToggleGroup<String>(
                    value: {_show},
                    variant: ToggleVariant.outline,
                    size: ToggleSize.sm,
                    semanticLabel: 'Show',
                    onChanged: (next) {
                      if (next.firstOrNull case final show?) {
                        setState(() => _show = show);
                      }
                    },
                    children: const [
                      ToggleGroupItem(value: 'all', child: Text('All')),
                      ToggleGroupItem(value: 'in', child: Text('Money in')),
                      ToggleGroupItem(value: 'out', child: Text('Money out')),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: _searchMin,
                      maxWidth: _searchMax,
                    ),
                    child: Input(
                      controller: _query,
                      placeholder: 'Search transactions',
                      semanticLabel: 'Search transactions',
                    ),
                  ),
                ],
              ),
              InkTable(
                columnWidths: {
                  1: MinColumnWidth(
                    FixedColumnWidth(switch (medium) {
                      true => Spacing.d256,
                      false => Spacing.d160,
                    }),
                    const IntrinsicColumnWidth(flex: 1),
                  ),
                },
                caption: Semantics(
                  label:
                      'Transactions in ${widget.monthName}, newest first unless you sort them otherwise',
                  child: const SizedBox.shrink(),
                ),
                header: TableHeader(
                  rows: [
                    InkTableRow(
                      cells: [
                        DashboardFinanceSortHead(
                          label: 'Date',
                          sort: _sortOf('date'),
                          onSort: () => _sort('date'),
                        ),
                        const TableHead(child: Text('What')),
                        if (large) const TableHead(child: Text('Pot')),
                        if (medium) const TableHead(child: Text('Status')),
                        DashboardFinanceSortHead(
                          label: 'Amount',
                          sort: _sortOf('amount'),
                          onSort: () => _sort('amount'),
                          end: true,
                        ),
                      ],
                    ),
                  ],
                ),
                body: TableBody(
                  rows: [
                    for (final t in rows)
                      _row(theme, t, medium: medium, large: large),
                  ],
                ),
              ),
              if (rows.isEmpty)
                const Empty(
                  children: [
                    EmptyHeader(
                      children: [
                        EmptyMedia(pose: 'search', size: 72),
                        EmptyTitle(child: Text('Nothing matches')),
                        EmptyDescription(
                          child: Text(
                            'Try another word, or show everything again.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  InkTableRow _row(
    LooseleafThemeData theme,
    FinanceTransaction t, {
    required bool medium,
    required bool large,
  }) {
    final status = _status[t.status] ?? _status.values.first;
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return InkTableRow(
      cells: [
        InkTableCell(child: Text(financeShortDate(t.date))),
        InkTableCell(
          wrap: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.description,
                maxLines: switch (medium) {
                  true => 1,
                  false => null,
                },
                overflow: switch (medium) {
                  true => TextOverflow.ellipsis,
                  false => null,
                },
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: t.account),
                    if (!medium && t.status != FinanceStatus.cleared)
                      TextSpan(
                        text: ' · ${status.label.toLowerCase()}',
                        style: switch (t.status) {
                          FinanceStatus.flagged => TextStyle(
                            color: theme.colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                          _ => null,
                        },
                      ),
                  ],
                ),
                style: muted,
              ),
            ],
          ),
        ),
        if (large)
          InkTableCell(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d6,
              children: [
                InkIcon(
                  financeCategoryIcon[t.category] ?? 'wallet',
                  size: Spacing.d14,
                ),
                Text(
                  t.category,
                  style: muted.copyWith(color: theme.colors.ink),
                ),
              ],
            ),
          ),
        if (medium)
          InkTableCell(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Badge(
                variant: status.variant,
                leading: InkIcon(
                  status.icon,
                  color: switch (t.status) {
                    FinanceStatus.cleared => theme.colors.green,
                    _ => null,
                  },
                ),
                child: Text(status.label),
              ),
            ),
          ),
        InkTableCell(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              financeMoney(t.cents, sign: true),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: switch (t.cents > 0) {
                  true => theme.colors.green,
                  false => null,
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
