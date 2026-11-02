import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The proposal's sections: views as tabs (a select on narrow pages), a
/// columns menu, an add button, the outline table with its pager, and an
/// empty state for every other view.
///
/// Mirrors `DataTable` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-data-table.tsx`.
class Dashboard01DataTable extends StatefulWidget {
  const Dashboard01DataTable({
    super.key,
    this.initialRows = dashboard01Sections,
  });

  final List<Dashboard01Section> initialRows;

  @override
  State<Dashboard01DataTable> createState() => _Dashboard01DataTableState();
}

class _Dashboard01DataTableState extends State<Dashboard01DataTable> {
  static const double _tabsFrom = 1080;

  /// Upstream's `lg` window, less the sidebar.
  static const double _wideFrom = 720;
  static const double _columnsMenuWidth = 224;
  static const double _narrowHeader = 160;
  static const double _wideHeader = 192;
  static const double _wideHeaderFrom = 672;

  static const _views = [
    (value: 'outline', label: 'Outline', count: null),
    (value: 'past-performance', label: 'Past performance', count: 3),
    (value: 'key-personnel', label: 'Key personnel', count: 2),
    (value: 'focus-documents', label: 'Focus documents', count: null),
  ];

  late var _rows = [...widget.initialRows];
  var _selected = <int>{};
  var _favorites = <int>{};
  var _hidden = <Dashboard01Column>{};
  var _pageIndex = 0;
  var _pageSize = 10;
  var _view = 'outline';
  var _note = '';

  int get _pageCount => math.max(1, (_rows.length / _pageSize).ceil());
  int get _page => _pageIndex.clamp(0, _pageCount - 1);
  int get _nextId =>
      _rows.fold(
        0,
        (top, row) => switch (row.id > top) {
          true => row.id,
          false => top,
        },
      ) +
      1;

  List<Dashboard01Section> get _pageRows =>
      _rows.skip(_page * _pageSize).take(_pageSize).toList();

  static Set<T> _toggle<T>(Set<T> set, T value, bool on) => switch (on) {
    true => {...set, value},
    false => {...set}..remove(value),
  };

  void _update(int id, Dashboard01Section next) => setState(
    () => _rows = [
      for (final row in _rows)
        switch (row.id == id) {
          true => next.copyWith(id: id),
          false => row,
        },
    ],
  );

  void _add() => setState(() {
    _rows = [
      ..._rows,
      Dashboard01Section(
        id: _nextId,
        header: 'Untitled section',
        type: 'Narrative',
        status: Dashboard01Status.notStarted,
        target: '0',
        limit: '0',
        reviewer: dashboard01Unassigned,
      ),
    ];
    _pageIndex = (_rows.length / _pageSize).ceil() - 1;
    _note = 'Added a blank section at the end of the table.';
  });

  void _copy(Dashboard01Section row) => setState(() {
    final at = _rows.indexWhere((other) => other.id == row.id);
    _rows = [
      ..._rows.take(at + 1),
      row.copyWith(id: _nextId, header: '${row.header} (copy)'),
      ..._rows.skip(at + 1),
    ];
    _note = 'Made a copy of ${row.header}.';
  });

  void _favorite(Dashboard01Section row) => setState(() {
    final on = !_favorites.contains(row.id);
    _favorites = _toggle(_favorites, row.id, on);
    _note = switch (on) {
      true => '${row.header} is a favorite now.',
      false => '${row.header} is no longer a favorite.',
    };
  });

  void _delete(Dashboard01Section row) => setState(() {
    _rows = [
      for (final other in _rows)
        if (other.id != row.id) other,
    ];
    _selected = _toggle(_selected, row.id, false);
    _note = 'Deleted ${row.header}.';
  });

  Widget _viewPicker(bool tabs) {
    if (tabs) {
      return TabsList(
        children: [
          for (final view in _views)
            TabsTrigger(
              value: view.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d6,
                children: [
                  Text(view.label),
                  if (view.count case final count?)
                    Badge(
                      variant: BadgeVariant.secondary,
                      size: BadgeSize.sm,
                      count: count,
                    ),
                ],
              ),
            ),
        ],
      );
    }
    return Select(
      value: _view,
      onChanged: (value) => setState(() => _view = value),
      content: SelectContent(
        children: [
          for (final view in _views)
            SelectItem(value: view.value, child: Text(view.label)),
        ],
      ),
      child: const SelectTrigger(
        size: SelectSize.sm,
        semanticLabel: 'View',
        child: SelectValue(placeholder: 'Pick a view'),
      ),
    );
  }

  Widget _toolbar(bool tabs, bool wide) => Row(
    spacing: Spacing.d8,
    children: [
      Expanded(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _viewPicker(tabs),
        ),
      ),
      DropdownMenu(
        content: DropdownMenuContent(
          align: OverlayAlign.end,
          width: _columnsMenuWidth,
          children: [
            for (final column in Dashboard01Column.values)
              DropdownMenuCheckboxItem(
                value: !_hidden.contains(column),
                onChanged: (on) =>
                    setState(() => _hidden = _toggle(_hidden, column, !on)),
                child: Text(column.label),
              ),
          ],
        ),
        child: DropdownMenuTrigger.builder(
          builder: (context, menu) => Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
            onPressed: menu.toggle,
            leading: const InkIcon('layout-grid'),
            trailing: const InkIcon('chevron-down'),
            child: Text(switch (wide) {
              true => 'Customize columns',
              false => 'Columns',
            }),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.d4),
        child: Button(
          variant: ButtonVariant.outline,
          size: switch (wide) {
            true => ButtonSize.sm,
            false => ButtonSize.iconSm,
          },
          semanticLabel: 'Add section',
          onPressed: _add,
          leading: switch (wide) {
            true => const InkIcon('plus'),
            false => null,
          },
          child: switch (wide) {
            true => const Text('Add section'),
            false => const InkIcon('plus'),
          },
        ),
      ),
    ],
  );

  Widget _outline(double width) {
    final pageRows = _pageRows;
    final columns = [
      for (final column in Dashboard01Column.values)
        if (!_hidden.contains(column) && width >= column.showsFrom) column,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Dashboard01OutlineTable(
          rows: pageRows,
          columns: columns,
          selected: _selected,
          favorites: _favorites,
          onSelect: (id, on) =>
              setState(() => _selected = _toggle(_selected, id, on)),
          onSelectPage: (on) => setState(
            () => _selected = pageRows.fold(
              _selected,
              (set, row) => _toggle(set, row.id, on),
            ),
          ),
          onUpdate: _update,
          onCopy: _copy,
          onFavorite: _favorite,
          onDelete: _delete,
          headerMaxWidth: switch (width >= _wideHeaderFrom) {
            true => _wideHeader,
            false => _narrowHeader,
          },
        ),
        if (pageRows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.d40),
            child: Text(
              'Nothing here. Add a section to start the outline.',
              textAlign: TextAlign.center,
            ),
          ),
        Dashboard01Pager(
          page: _page,
          pageCount: _pageCount,
          pageSize: _pageSize,
          selectedCount: _selected.length,
          rowCount: _rows.length,
          onPage: (page) => setState(() => _pageIndex = page),
          onPageSize: (size) => setState(() {
            _pageSize = size;
            _pageIndex = 0;
          }),
        ),
        Semantics(
          liveRegion: true,
          label: _note,
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= _wideFrom;
        final pad = EdgeInsets.symmetric(
          horizontal: switch (wide) {
            true => Spacing.d24,
            false => Spacing.d16,
          },
        );
        return Semantics(
          container: true,
          label: 'Document sections',
          child: Tabs(
            value: _view,
            onValueChange: (value) => setState(() => _view = value),
            children: [
              Padding(
                padding: pad,
                child: _toolbar(width >= _tabsFrom, wide),
              ),
              const SizedBox(height: Spacing.d12),
              for (final view in _views)
                TabsContent(
                  value: view.value,
                  child: Padding(
                    padding: pad,
                    child: switch (view.value) {
                      'outline' => _outline(width),
                      _ => Empty(
                        framed: true,
                        children: [
                          EmptyHeader(
                            children: [
                              const EmptyMedia(pose: 'sleep', size: 88),
                              EmptyTitle(
                                child: Text(
                                  'Nothing filed under ${view.label.toLowerCase()} yet',
                                ),
                              ),
                              const EmptyDescription(
                                child: Text(
                                  'Sections you tag this way will turn up here.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
