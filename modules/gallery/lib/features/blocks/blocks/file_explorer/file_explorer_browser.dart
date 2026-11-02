import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One drawer's contents: where you are, a search box, the sort, list or
/// grid, a new-folder button, what is picked, an undo after a delete, and
/// the files themselves (or an empty state).
class FileExplorerBrowser extends StatelessWidget {
  const FileExplorerBrowser({
    super.key,
    required this.rootName,
    required this.trail,
    required this.items,
    required this.view,
    required this.onView,
    required this.sort,
    required this.onSort,
    required this.search,
    required this.selected,
    required this.onSelect,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onActivate,
    required this.onDelete,
    required this.onDeleteSelected,
    required this.onNewFolder,
    required this.onCrumb,
    required this.undo,
    required this.onUndo,
    required this.empty,
  });

  final String rootName;
  final List<({String id, String name})> trail;
  final List<FileExplorerItem> items;
  final FileExplorerView view;
  final ValueChanged<FileExplorerView> onView;
  final FileExplorerSortKey sort;
  final ValueChanged<FileExplorerSortKey> onSort;
  final TextEditingController search;
  final Set<String> selected;
  final void Function(String id, bool on) onSelect;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onClearSelection;
  final ValueChanged<FileExplorerItem> onActivate;
  final ValueChanged<FileExplorerItem> onDelete;
  final VoidCallback onDeleteSelected;
  final VoidCallback onNewFolder;
  final ValueChanged<int> onCrumb;
  final String? undo;
  final VoidCallback onUndo;

  /// True when the folder holds nothing at all (not just no matches).
  final bool empty;

  static const double _searchWidth = 256;
  static const double _sortWidth = 160;
  static const double _searchMinWidth = 160;

  /// Upstream's `sm:` (640 px) less the page's padding.
  static const double _wide = 560;

  Widget _breadcrumb() => Breadcrumb(
    label: 'Where you are in $rootName',
    child: BreadcrumbList(
      children: [
        BreadcrumbItem(
          children: [
            switch (trail) {
              [] => BreadcrumbPage(child: Text(rootName)),
              _ => BreadcrumbLink(
                onPressed: () => onCrumb(0),
                child: Text(rootName),
              ),
            },
          ],
        ),
        for (final (index, crumb) in trail.indexed) ...[
          const BreadcrumbSeparator(),
          BreadcrumbItem(
            children: [
              switch (index == trail.length - 1) {
                true => BreadcrumbPage(child: Text(crumb.name)),
                false => BreadcrumbLink(
                  onPressed: () => onCrumb(index + 1),
                  child: Text(crumb.name),
                ),
              },
            ],
          ),
        ],
      ],
    ),
  );

  Widget _toolbar(double width, String here) {
    final wide = width >= _wide;
    return Wrap(
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: switch ((wide, width - _sortWidth - Spacing.d12)) {
            (true, _) => _searchWidth,
            (false, final rest) when rest >= _searchMinWidth => rest,
            _ => width,
          },
          child: Input(
            controller: search,
            keyboardType: TextInputType.text,
            placeholder: 'Search this folder',
            semanticLabel: 'Search in $here',
          ),
        ),
        SizedBox(
          width: _sortWidth,
          child: Select(
            value: sort.name,
            onChanged: (name) =>
                onSort(FileExplorerSortKey.values.byName(name)),
            content: SelectContent(
              children: [
                for (final key in FileExplorerSortKey.values)
                  SelectItem(value: key.name, child: Text(key.label)),
              ],
            ),
            child: const SelectTrigger(
              size: SelectSize.sm,
              semanticLabel: 'Sort by',
            ),
          ),
        ),
        ToggleGroup<FileExplorerView>(
          variant: ToggleVariant.outline,
          size: ToggleSize.sm,
          value: {view},
          onChanged: (value) {
            if (value.firstOrNull case final picked?) onView(picked);
          },
          semanticLabel: 'View',
          children: const [
            ToggleGroupItem(
              value: FileExplorerView.list,
              semanticLabel: 'List view',
              child: InkIcon('list'),
            ),
            ToggleGroupItem(
              value: FileExplorerView.grid,
              semanticLabel: 'Grid view',
              child: InkIcon('layout-grid'),
            ),
          ],
        ),
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          leading: const InkIcon('folder-plus'),
          onPressed: onNewFolder,
          child: const Text('New folder'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final here = trail.lastOrNull?.name ?? rootName;
    final undo = this.undo;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            _breadcrumb(),
            _toolbar(width, here),
            if (selected.isNotEmpty)
              Semantics(
                container: true,
                label: 'Selected items',
                child: ColoredBox(
                  color: theme.colors.hiSelect.withValues(
                    alpha: theme.colors.hiSelect.a / 2,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.d12,
                      vertical: Spacing.d6,
                    ),
                    child: Wrap(
                      spacing: Spacing.d12,
                      runSpacing: Spacing.d8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${selected.length} picked',
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            fontWeight: FontWeight.w700,
                            color: theme.colors.ink,
                          ),
                        ),
                        Button(
                          variant: ButtonVariant.destructive,
                          size: ButtonSize.sm,
                          leading: const InkIcon('trash'),
                          onPressed: onDeleteSelected,
                          child: const Text('Delete'),
                        ),
                        Button(
                          variant: ButtonVariant.ghost,
                          size: ButtonSize.sm,
                          onPressed: onClearSelection,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (undo != null)
              Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(undo, style: theme.typography.interface(cssSize: 14)),
                  Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.sm,
                    onPressed: onUndo,
                    child: const Text('Undo'),
                  ),
                ],
              ),
            switch ((items.isEmpty, view)) {
              (true, _) => Empty(
                children: [
                  EmptyHeader(
                    children: [
                      EmptyMedia(
                        pose: switch (empty) {
                          true => 'peek',
                          false => 'search',
                        },
                        size: 84,
                      ),
                      EmptyTitle(
                        child: Text(switch (empty) {
                          true => 'This folder is empty',
                          false => 'Nothing matches',
                        }),
                      ),
                      EmptyDescription(
                        child: Text(switch (empty) {
                          true => 'Nothing filed here yet. Make a new folder to begin.',
                          false => 'Try another word.',
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              (false, FileExplorerView.list) => Semantics(
                container: true,
                label: 'Everything in $here',
                child: FileExplorerListView(
                  items: items,
                  selected: selected,
                  wide: width >= _wide,
                  onActivate: onActivate,
                  onSelect: onSelect,
                  onSelectAll: onSelectAll,
                  onDelete: onDelete,
                ),
              ),
              (false, FileExplorerView.grid) => Semantics(
                container: true,
                label: 'Everything in $here',
                child: FileExplorerGridView(
                  items: items,
                  selected: selected,
                  columns: switch (width) {
                    >= 896 => 4,
                    >= _wide => 3,
                    _ => 2,
                  },
                  onActivate: onActivate,
                  onSelect: onSelect,
                  onDelete: onDelete,
                ),
              ),
            },
          ],
        );
      },
    );
  }
}
