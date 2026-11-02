import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Column { status, email, amount }

typedef _Payment = ({String id, int amount, String status, String email});

const List<_Payment> _data = [
  (id: 'm5gr84i9', amount: 316, status: 'success', email: 'ken99@example.com'),
  (id: '3u1reuv4', amount: 242, status: 'success', email: 'Abe45@example.com'),
  (
    id: 'derv1ws0',
    amount: 837,
    status: 'processing',
    email: 'Monserrat44@example.com',
  ),
  (
    id: '5kma53ae',
    amount: 874,
    status: 'success',
    email: 'Silas22@example.com',
  ),
  (
    id: 'bhqecj4p',
    amount: 721,
    status: 'failed',
    email: 'carmella@example.com',
  ),
  (
    id: 'p0d9x2lq',
    amount: 129,
    status: 'pending',
    email: 'jo.okafor@example.com',
  ),
  (id: 'v7t3n8ws', amount: 458, status: 'success', email: 'mika.k@example.com'),
  (
    id: 'c2h6y1rb',
    amount: 63,
    status: 'failed',
    email: 'sam.reyes@example.com',
  ),
  (
    id: 'k9f4a5ze',
    amount: 590,
    status: 'processing',
    email: 'priya@example.com',
  ),
  (
    id: 'x3m8u0dj',
    amount: 205,
    status: 'success',
    email: 'tomas.berg@example.com',
  ),
  (id: 'q1w7e5tn', amount: 912, status: 'pending', email: 'lena.f@example.com'),
  (id: 'z6b2g4ho', amount: 377, status: 'success', email: 'omar@example.com'),
];

const _pageSize = 5;

String _capitalized(String word) =>
    '${word[0].toUpperCase()}${word.substring(1)}';

class TableDataTableDemoExample extends StatefulWidget {
  const TableDataTableDemoExample({super.key});

  @override
  State<TableDataTableDemoExample> createState() =>
      _TableDataTableDemoExampleState();
}

class _TableDataTableDemoExampleState extends State<TableDataTableDemoExample> {
  static const _filterWidth = Spacing.d384;

  final _filter = TextEditingController();
  bool? _ascending;
  final _visible = {..._Column.values};
  var _selection = <String>{};
  int _pageIndex = 0;

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  List<_Payment> get _rows {
    final query = _filter.text.toLowerCase();
    final found = [
      for (final payment in _data)
        if (payment.email.toLowerCase().contains(query)) payment,
    ];
    final ascending = _ascending;
    if (ascending == null) return found;
    final sign = switch (ascending) {
      true => 1,
      false => -1,
    };
    return found..sort(
      (a, b) => sign * a.email.toLowerCase().compareTo(b.email.toLowerCase()),
    );
  }

  void _toggle(Iterable<String> ids, bool on) => setState(() {
    _selection = {..._selection};
    if (on) {
      _selection.addAll(ids);
      return;
    }
    _selection.removeAll(ids);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final rows = _rows;
    final pageCount = math.max(1, (rows.length / _pageSize).ceil());
    final page = math.min(_pageIndex, pageCount - 1);
    final pageRows = rows.skip(page * _pageSize).take(_pageSize).toList();
    final chosenOnPage = pageRows
        .where((payment) => _selection.contains(payment.id))
        .length;
    final chosenInFilter = rows
        .where((payment) => _selection.contains(payment.id))
        .length;
    final columns = [
      for (final column in _Column.values)
        if (_visible.contains(column)) column,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
          child: Row(
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _filterWidth),
                  child: Input(
                    controller: _filter,
                    placeholder: 'Filter emails...',
                    semanticLabel: 'Filter emails',
                    onChanged: (_) => setState(() => _pageIndex = 0),
                  ),
                ),
              ),
              const Spacer(),
              DropdownMenu(
                content: DropdownMenuContent(
                  align: OverlayAlign.end,
                  children: [
                    for (final column in _Column.values)
                      DropdownMenuCheckboxItem(
                        value: _visible.contains(column),
                        onChanged: (on) => setState(() {
                          if (on) {
                            _visible.add(column);
                            return;
                          }
                          _visible.remove(column);
                        }),
                        child: Text(_capitalized(column.name)),
                      ),
                  ],
                ),
                child: DropdownMenuTrigger.builder(
                  builder: (context, menu) => Button(
                    variant: ButtonVariant.outline,
                    onPressed: menu.toggle,
                    trailing: const InkIcon('chevron-down'),
                    child: const Text('Columns'),
                  ),
                ),
              ),
            ],
          ),
        ),
        InkTable(
          header: TableHeader(
            rows: [
              InkTableRow(
                cells: [
                  TableHead(
                    child: Checkbox(
                      semanticLabel: 'Select all',
                      value: switch (chosenOnPage) {
                        0 => false,
                        _ when chosenOnPage == pageRows.length => true,
                        _ => null,
                      },
                      onChanged: (on) =>
                          _toggle(pageRows.map((payment) => payment.id), on),
                    ),
                  ),
                  for (final column in columns)
                    switch (column) {
                      _Column.status => const TableHead(child: Text('Status')),
                      _Column.email => TableHead(
                        sort: switch (_ascending) {
                          true => TableSort.ascending,
                          false => TableSort.descending,
                          null => null,
                        },
                        child: Button(
                          variant: ButtonVariant.ghost,
                          onPressed: () => setState(
                            () => _ascending = !(_ascending ?? false),
                          ),
                          trailing: const InkIcon('arrow-up-down'),
                          child: const Text('Email'),
                        ),
                      ),
                      _Column.amount => const TableHead(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text('Amount'),
                        ),
                      ),
                    },
                  TableHead(
                    child: Semantics(
                      label: 'Actions',
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: TableBody(
            rows: [
              for (final payment in pageRows)
                InkTableRow(
                  selected: _selection.contains(payment.id),
                  cells: [
                    InkTableCell(
                      child: Checkbox(
                        semanticLabel: 'Select ${payment.email}',
                        value: _selection.contains(payment.id),
                        onChanged: (on) => _toggle([payment.id], on),
                      ),
                    ),
                    for (final column in columns)
                      InkTableCell(
                        child: switch (column) {
                          _Column.status => Text(_capitalized(payment.status)),
                          _Column.email => Text(payment.email.toLowerCase()),
                          _Column.amount => Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              '\$${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        },
                      ),
                    InkTableCell(
                      child: DropdownMenu(
                        content: DropdownMenuContent(
                          align: OverlayAlign.end,
                          children: [
                            const DropdownMenuLabel(child: Text('Actions')),
                            DropdownMenuItem(
                              onSelect: () => unawaited(
                                Clipboard.setData(
                                  ClipboardData(text: payment.id),
                                ),
                              ),
                              child: const Text('Copy payment ID'),
                            ),
                            const DropdownMenuSeparator(),
                            DropdownMenuItem(
                              onSelect: () {},
                              child: const Text('View customer'),
                            ),
                            DropdownMenuItem(
                              onSelect: () {},
                              child: const Text('View payment details'),
                            ),
                          ],
                        ),
                        child: DropdownMenuTrigger.builder(
                          builder: (context, menu) => Button(
                            variant: ButtonVariant.ghost,
                            size: ButtonSize.iconSm,
                            semanticLabel: 'Open menu',
                            onPressed: menu.toggle,
                            child: const InkIcon('ellipsis'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (pageRows.isEmpty)
                InkTableRow(
                  cells: [
                    InkTableCell(
                      colSpan: columns.length + 2,
                      child: const SizedBox(
                        height: Spacing.d80,
                        child: Center(child: Text('No results.')),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
          child: Row(
            spacing: Spacing.d8,
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    '$chosenInFilter of ${rows.length} row(s) selected. Page ${page + 1} of $pageCount.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: page == 0,
                onPressed: () => setState(() => _pageIndex = page - 1),
                child: const Text('Previous'),
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: page >= pageCount - 1,
                onPressed: () => setState(() => _pageIndex = page + 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
