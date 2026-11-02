import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One page of the proposal's sections: a tick box per row, the columns
/// that fit and are not hidden, editable targets and limits, a reviewer
/// picker for unassigned rows and a menu of row actions.
class Dashboard01OutlineTable extends StatelessWidget {
  const Dashboard01OutlineTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.selected,
    required this.favorites,
    required this.onSelect,
    required this.onSelectPage,
    required this.onUpdate,
    required this.onCopy,
    required this.onFavorite,
    required this.onDelete,
    this.headerMaxWidth = 192,
  });

  static const double _tickWidth = 40;
  static const double _actionsWidth = 60;
  static const double _numberWidth = 80;
  static const double _reviewerWidth = 144;
  static const double _menuWidth = 160;

  /// The rows on this page.
  final List<Dashboard01Section> rows;

  /// The data columns shown, in order.
  final List<Dashboard01Column> columns;
  final Set<int> selected;
  final Set<int> favorites;
  final void Function(int id, bool selected) onSelect;
  final ValueChanged<bool> onSelectPage;
  final void Function(int id, Dashboard01Section next) onUpdate;
  final ValueChanged<Dashboard01Section> onCopy;
  final ValueChanged<Dashboard01Section> onFavorite;
  final ValueChanged<Dashboard01Section> onDelete;

  /// How wide a section's header may get before it is cut short.
  final double headerMaxWidth;

  bool? get _pageTick {
    final ticked = rows.where((row) => selected.contains(row.id)).length;
    if (rows.isNotEmpty && ticked == rows.length) return true;
    if (ticked > 0) return null;
    return false;
  }

  Map<int, TableColumnWidth> get _widths => {
    0: const FixedColumnWidth(_tickWidth),
    for (final (index, column) in columns.indexed)
      if (column == Dashboard01Column.target ||
          column == Dashboard01Column.limit)
        index + 1: const FixedColumnWidth(_numberWidth),
    columns.length + 1: const FixedColumnWidth(_actionsWidth),
  };

  Widget _head(Dashboard01Column column) => TableHead(
    child: switch (column) {
      Dashboard01Column.target || Dashboard01Column.limit => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Text(column.label),
      ),
      _ => Text(column.label),
    },
  );

  Widget _cell(
    Dashboard01Column column,
    Dashboard01Section row,
    LooseleafThemeData theme,
  ) => switch (column) {
    Dashboard01Column.header => InkTableCell(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: headerMaxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d6,
          children: [
            Flexible(
              child: Dashboard01SectionViewer(
                item: row,
                onSave: (next) => onUpdate(row.id, next),
              ),
            ),
            if (favorites.contains(row.id))
              InkIcon(
                'star',
                size: Spacing.d14,
                color: theme.colors.hiDeep,
                semanticLabel: 'Favorite',
              ),
          ],
        ),
      ),
    ),
    Dashboard01Column.type => InkTableCell(
      child: Badge(
        variant: BadgeVariant.outline,
        child: Text(
          row.type,
          style: TextStyle(color: theme.colors.inkSoft),
        ),
      ),
    ),
    Dashboard01Column.status => InkTableCell(
      child: Badge(
        variant: BadgeVariant.outline,
        leading: InkIcon(
          row.status.icon,
          color: switch (row.status) {
            Dashboard01Status.done => theme.colors.green,
            _ => null,
          },
        ),
        child: Text(
          row.status.label,
          style: TextStyle(color: theme.colors.inkSoft),
        ),
      ),
    ),
    Dashboard01Column.target => InkTableCell(
      child: Dashboard01NumberCell(
        value: row.target,
        semanticLabel: 'Target for ${row.header}',
        onChanged: (value) => onUpdate(row.id, row.copyWith(target: value)),
      ),
    ),
    Dashboard01Column.limit => InkTableCell(
      child: Dashboard01NumberCell(
        value: row.limit,
        semanticLabel: 'Limit for ${row.header}',
        onChanged: (value) => onUpdate(row.id, row.copyWith(limit: value)),
      ),
    ),
    Dashboard01Column.reviewer => InkTableCell(
      child: switch (row.reviewer == dashboard01Unassigned) {
        false => Text(row.reviewer),
        true => SizedBox(
          width: _reviewerWidth,
          child: Select(
            onChanged: (value) =>
                onUpdate(row.id, row.copyWith(reviewer: value)),
            content: SelectContent(
              align: OverlayAlign.end,
              children: [
                for (final reviewer in dashboard01Reviewers)
                  SelectItem(value: reviewer, child: Text(reviewer)),
              ],
            ),
            child: SelectTrigger(
              size: SelectSize.sm,
              semanticLabel: 'Assign a reviewer to ${row.header}',
              child: const SelectValue(placeholder: 'Assign reviewer'),
            ),
          ),
        ),
      },
    ),
  };

  Widget _actions(Dashboard01Section row, LooseleafThemeData theme) =>
      DropdownMenu(
        content: DropdownMenuContent(
          align: OverlayAlign.end,
          width: _menuWidth,
          children: [
            DropdownMenuItem(
              leading: const InkIcon('copy'),
              onSelect: () => onCopy(row),
              child: const Text('Make a copy'),
            ),
            DropdownMenuItem(
              leading: const InkIcon('star'),
              onSelect: () => onFavorite(row),
              child: Text(switch (favorites.contains(row.id)) {
                true => 'Unfavorite',
                false => 'Favorite',
              }),
            ),
            const DropdownMenuSeparator(),
            DropdownMenuItem(
              variant: InkMenuItemVariant.destructive,
              leading: const InkIcon('trash'),
              onSelect: () => onDelete(row),
              child: const Text('Delete'),
            ),
          ],
        ),
        child: DropdownMenuTrigger.builder(
          builder: (context, menu) => Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.icon,
            semanticLabel: 'Actions for ${row.header}',
            onPressed: menu.toggle,
            child: InkIcon('ellipsis-vertical', color: theme.colors.inkSoft),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      label: 'Document sections',
      child: InkTable(
        columnWidths: _widths,
        header: TableHeader(
          rows: [
            InkTableRow(
              cells: [
                TableHead(
                  child: Checkbox(
                    value: _pageTick,
                    semanticLabel: 'Select all rows on this page',
                    onChanged: onSelectPage,
                  ),
                ),
                for (final column in columns) _head(column),
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
            for (final row in rows)
              InkTableRow(
                selected: selected.contains(row.id),
                cells: [
                  InkTableCell(
                    child: Checkbox(
                      value: selected.contains(row.id),
                      semanticLabel: 'Select ${row.header}',
                      onChanged: (on) => onSelect(row.id, on),
                    ),
                  ),
                  for (final column in columns) _cell(column, row, theme),
                  InkTableCell(child: _actions(row, theme)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
