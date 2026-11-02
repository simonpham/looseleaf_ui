import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Plan { solo, team }

enum _Status { paid, pending, overdue }

enum _SortKey { name, plan, status, amount }

typedef _Person = ({
  String id,
  String name,
  _Plan plan,
  _Status status,
  int amount,
});

typedef _Sort = ({_SortKey key, bool ascending});

const List<_Person> _data = [
  (
    id: '1',
    name: 'Ada Lovelace',
    plan: _Plan.team,
    status: _Status.paid,
    amount: 250,
  ),
  (
    id: '2',
    name: 'Jo Okafor',
    plan: _Plan.solo,
    status: _Status.pending,
    amount: 49,
  ),
  (
    id: '3',
    name: 'Mika Kobayashi',
    plan: _Plan.team,
    status: _Status.paid,
    amount: 250,
  ),
  (
    id: '4',
    name: 'Sam Reyes',
    plan: _Plan.solo,
    status: _Status.overdue,
    amount: 49,
  ),
  (
    id: '5',
    name: 'Priya Nair',
    plan: _Plan.team,
    status: _Status.paid,
    amount: 250,
  ),
  (
    id: '6',
    name: 'Tomas Berg',
    plan: _Plan.solo,
    status: _Status.paid,
    amount: 49,
  ),
  (
    id: '7',
    name: 'Lena Fischer',
    plan: _Plan.team,
    status: _Status.pending,
    amount: 250,
  ),
  (
    id: '8',
    name: 'Omar Haddad',
    plan: _Plan.solo,
    status: _Status.paid,
    amount: 49,
  ),
  (
    id: '9',
    name: 'Yuki Tanaka',
    plan: _Plan.team,
    status: _Status.overdue,
    amount: 250,
  ),
  (
    id: '10',
    name: 'Ines Moreau',
    plan: _Plan.solo,
    status: _Status.paid,
    amount: 49,
  ),
  (
    id: '11',
    name: 'Kofi Mensah',
    plan: _Plan.team,
    status: _Status.paid,
    amount: 250,
  ),
  (
    id: '12',
    name: 'Nora Lindqvist',
    plan: _Plan.solo,
    status: _Status.pending,
    amount: 49,
  ),
];

const _pageSize = 5;

String _label(Enum value) =>
    '${value.name[0].toUpperCase()}${value.name.substring(1)}';

class TableDataTableExample extends StatefulWidget {
  const TableDataTableExample({super.key});

  @override
  State<TableDataTableExample> createState() => _TableDataTableExampleState();
}

class _TableDataTableExampleState extends State<TableDataTableExample> {
  static const _maxWidth = 672.0;

  _Sort? _sort;
  var _selected = <String>{'3'};
  int _page = 0;

  List<_Person> get _rows {
    final sort = _sort;
    if (sort == null) return _data;
    final sign = switch (sort.ascending) {
      true => 1,
      false => -1,
    };
    return [..._data]..sort(
      (a, b) =>
          sign *
          switch (sort.key) {
            _SortKey.name => a.name.compareTo(b.name),
            _SortKey.plan => _label(a.plan).compareTo(_label(b.plan)),
            _SortKey.status => _label(a.status).compareTo(_label(b.status)),
            _SortKey.amount => a.amount.compareTo(b.amount),
          },
    );
  }

  void _toggleSort(_SortKey key) => setState(
    () => _sort = switch (_sort) {
      (key: final current, ascending: _) when current != key => (
        key: key,
        ascending: true,
      ),
      null => (key: key, ascending: true),
      (key: _, ascending: true) => (key: key, ascending: false),
      (key: _, ascending: false) => null,
    },
  );

  void _toggle(Iterable<String> ids, bool on) => setState(() {
    _selected = {..._selected};
    if (on) {
      _selected.addAll(ids);
      return;
    }
    _selected.removeAll(ids);
  });

  TableHead _head(String label, _SortKey key, {bool end = false}) {
    final sort = _sort;
    final active = sort?.key == key;
    final direction = switch ((active, sort?.ascending)) {
      (true, true) => TableSort.ascending,
      (true, false) => TableSort.descending,
      _ => null,
    };
    final button = Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      onPressed: () => _toggleSort(key),
      trailing: Opacity(
        opacity: switch (active) {
          true => 1,
          false => 0.45,
        },
        child: InkIcon(switch (direction) {
          TableSort.ascending => 'arrow-up',
          TableSort.descending => 'arrow-down',
          null => 'chevrons-up-down',
        }),
      ),
      child: Text(label),
    );
    return TableHead(
      sort: direction,
      child: switch (end) {
        true => Align(alignment: AlignmentDirectional.centerEnd, child: button),
        false => button,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final rows = _rows;
    final pages = (rows.length / _pageSize).ceil();
    final visible = rows.skip(_page * _pageSize).take(_pageSize).toList();
    final chosen = visible.where((row) => _selected.contains(row.id)).length;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          InkTable(
            columnWidths: const {0: FixedColumnWidth(Spacing.d40)},
            header: TableHeader(
              rows: [
                InkTableRow(
                  cells: [
                    TableHead(
                      child: Checkbox(
                        semanticLabel: 'Select all rows on this page',
                        value: switch (chosen) {
                          0 => false,
                          _ when chosen == visible.length => true,
                          _ => null,
                        },
                        onChanged: (on) =>
                            _toggle(visible.map((row) => row.id), on),
                      ),
                    ),
                    _head('Name', _SortKey.name),
                    _head('Plan', _SortKey.plan),
                    _head('Status', _SortKey.status),
                    _head('Amount', _SortKey.amount, end: true),
                  ],
                ),
              ],
            ),
            body: TableBody(
              rows: [
                for (final row in visible)
                  InkTableRow(
                    selected: _selected.contains(row.id),
                    cells: [
                      InkTableCell(
                        child: Checkbox(
                          semanticLabel: 'Select ${row.name}',
                          value: _selected.contains(row.id),
                          onChanged: (on) => _toggle([row.id], on),
                        ),
                      ),
                      InkTableCell(
                        child: Text(
                          row.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      InkTableCell(child: Text(_label(row.plan))),
                      InkTableCell(
                        child: Text(
                          _label(row.status),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: switch ((
                              _selected.contains(row.id),
                              row.status,
                            )) {
                              (true, _) => colors.ink,
                              (false, _Status.paid) => colors.green,
                              (false, _Status.pending) => colors.inkMuted,
                              (false, _Status.overdue) => colors.red,
                            },
                          ),
                        ),
                      ),
                      InkTableCell(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '\$${row.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            spacing: Spacing.d16,
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    '${_selected.length} of ${_data.length} chosen · page ${_page + 1} of $pages',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: _page == 0,
                leading: const InkIcon('chevron-left'),
                onPressed: () => setState(() => _page -= 1),
                child: const Text('Previous'),
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: _page >= pages - 1,
                trailing: const InkIcon('chevron-right'),
                onPressed: () => setState(() => _page += 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
