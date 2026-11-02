import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The folder as a table: a tick box per row and one for everything,
/// the name, when it last changed and its size (folded under the name on
/// phones), and a menu per row.
class FileExplorerListView extends StatelessWidget {
  const FileExplorerListView({
    super.key,
    required this.items,
    required this.selected,
    required this.wide,
    required this.onActivate,
    required this.onSelect,
    required this.onSelectAll,
    required this.onDelete,
  });

  final List<FileExplorerItem> items;
  final Set<String> selected;

  /// Upstream's `sm:` breakpoint: shows the date and size columns.
  final bool wide;
  final ValueChanged<FileExplorerItem> onActivate;
  final void Function(String id, bool on) onSelect;
  final ValueChanged<bool> onSelectAll;
  final ValueChanged<FileExplorerItem> onDelete;

  @override
  Widget build(BuildContext context) {
    final picked = items.where((item) => selected.contains(item.id)).length;
    final last = switch (wide) {
      true => 4,
      false => 2,
    };
    const numbers = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    return InkTable(
      columnWidths: {
        0: const FixedColumnWidth(Spacing.d40),
        1: const FlexColumnWidth(2),
        last: const FixedColumnWidth(Spacing.d48),
      },
      header: TableHeader(
        rows: [
          InkTableRow(
            cells: [
              TableHead(
                child: Checkbox(
                  semanticLabel: 'Select everything in this folder',
                  value: switch (picked) {
                    0 => false,
                    _ when picked == items.length => true,
                    _ => null,
                  },
                  onChanged: (on) => onSelectAll(on == true),
                ),
              ),
              const TableHead(child: Text('Name')),
              if (wide) const TableHead(child: Text('Last changed')),
              if (wide)
                const TableHead(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text('Size'),
                  ),
                ),
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
          for (final item in items)
            InkTableRow(
              selected: selected.contains(item.id),
              cells: [
                InkTableCell(
                  child: Checkbox(
                    semanticLabel: 'Select ${item.name}',
                    value: selected.contains(item.id),
                    onChanged: (on) => onSelect(item.id, on == true),
                  ),
                ),
                InkTableCell(
                  child: FileExplorerOpenButton(
                    item: item,
                    showMeta: !wide,
                    onPressed: () => onActivate(item),
                  ),
                ),
                if (wide)
                  InkTableCell(
                    child: Text(
                      fileExplorerDay(item.node.modified),
                      style: numbers,
                    ),
                  ),
                if (wide)
                  InkTableCell(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        switch (item.isFolder) {
                          true => item.meta,
                          false => fileExplorerSize(item.node.size ?? 0),
                        },
                        style: numbers,
                      ),
                    ),
                  ),
                InkTableCell(
                  child: FileExplorerRowMenu(
                    item: item,
                    onActivate: onActivate,
                    onDelete: onDelete,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
