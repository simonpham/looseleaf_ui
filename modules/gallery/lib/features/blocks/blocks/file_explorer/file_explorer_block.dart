import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A filing cabinet: a kraft folder with a tab per drawer, a path you can
/// climb back up, search, sort, list or grid, picking files, deleting
/// them (with undo) and making new folders.
///
/// Mirrors upstream `src/blocks/file-explorer/page.tsx`.
class FileExplorerBlock extends StatefulWidget {
  const FileExplorerBlock({super.key});

  @override
  State<FileExplorerBlock> createState() => _FileExplorerBlockState();
}

class _FileExplorerBlockState extends State<FileExplorerBlock> {
  final _search = TextEditingController();
  List<FileExplorerNode> _all = fileExplorerNodes;
  String _rootId = fileExplorerRoots.first.id;
  Map<String, List<String>> _paths = {};
  FileExplorerView _view = FileExplorerView.list;
  FileExplorerSortKey _sort = FileExplorerSortKey.name;
  Set<String> _selected = {};
  ({String text, List<FileExplorerNode> nodes})? _undo;
  String _message = '';

  static const String _today = '2026-09-25';
  static const double _maxWidth = 1024;

  @override
  void initState() {
    super.initState();
    _search.addListener(_searched);
  }

  @override
  void dispose() {
    _search
      ..removeListener(_searched)
      ..dispose();
    super.dispose();
  }

  void _searched() => setState(() {});

  FileExplorerRoot get _root =>
      fileExplorerRoots.where((root) => root.id == _rootId).firstOrNull ??
      fileExplorerRoots.first;

  List<String> get _path => _paths[_root.id] ?? const [];

  String get _here => _path.lastOrNull ?? _root.id;

  List<FileExplorerNode> get _inside => [
    for (final node in _all)
      if (node.parent == _here) node,
  ];

  List<FileExplorerItem> get _items {
    final query = _search.text.trim().toLowerCase();
    final matching = switch (query) {
      '' => _inside,
      _ => _inside.where((node) => node.name.toLowerCase().contains(query)),
    };
    return [
      for (final node in fileExplorerSort(matching, _sort))
        switch (node.isFolder) {
          true => FileExplorerItem(
            node,
            items: fileExplorerCountIn(_all, node.id),
          ),
          false => FileExplorerItem(node),
        },
    ];
  }

  void _reset() {
    _selected = {};
    _undo = null;
    _search.clear();
  }

  void _go(List<String> next) => setState(() {
    _paths = {..._paths, _root.id: next};
    _reset();
  });

  void _activate(FileExplorerItem item) {
    if (item.isFolder) {
      _go([..._path, item.id]);
      setState(() => _message = 'Opened ${item.name}.');
      return;
    }
    setState(() {
      _selected = switch (_selected.contains(item.id)) {
        true => {..._selected}..remove(item.id),
        false => {..._selected, item.id},
      };
    });
  }

  void _remove(Iterable<String> ids, String what) {
    final doomed = <String>{
      for (final id in ids) ...fileExplorerWithDescendants(_all, id),
    };
    setState(() {
      _undo = (
        text: 'Deleted $what.',
        nodes: [
          for (final node in _all)
            if (doomed.contains(node.id)) node,
        ],
      );
      _all = [
        for (final node in _all)
          if (!doomed.contains(node.id)) node,
      ];
      _selected = {};
      _message = 'Deleted $what. Undo is next to the list.';
    });
  }

  void _newFolder() {
    final taken = {for (final node in _inside) node.name};
    var name = 'Untitled folder';
    for (var copy = 2; taken.contains(name); copy++) {
      name = 'Untitled folder $copy';
    }
    final next =
        _all
            .map((node) => int.tryParse(node.id.substring(1)) ?? 0)
            .fold(
              0,
              (most, id) => switch (id > most) {
                true => id,
                false => most,
              },
            ) +
        1;
    setState(() {
      _all = [
        ..._all,
        FileExplorerNode(
          id: 'f$next',
          parent: _here,
          name: name,
          kind: FileExplorerKind.folder,
          modified: _today,
        ),
      ];
      _undo = null;
      _message = 'Made a folder called $name.';
    });
  }

  void _undoDelete() {
    final undo = _undo;
    if (undo == null) return;
    setState(() {
      _all = [..._all, ...undo.nodes];
      _message = 'Put it back.';
      _undo = null;
    });
  }

  Widget _header(LooseleafThemeData theme, bool wide) {
    final files = _all.where((node) => !node.isFolder).length;
    final total = _all.fold(0.0, (sum, node) => sum + (node.size ?? 0));
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d16,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marigold Paper Co.',
                  style: theme.typography
                      .face(
                        KevinSansFace.type,
                        cssSize: 14,
                        cssLineHeight: 20 / 14,
                        color: theme.colors.inkMuted,
                      )
                      .copyWith(letterSpacing: 0.025 * 14),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    'Filing cabinet',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: switch (wide) {
                        true => 48,
                        false => 36,
                      },
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (wide)
              const Sticker('pencil-cup', size: 68, seed: 'files-pencils'),
          ],
        ),
        Text(
          '$files files, ${fileExplorerSize(total)}',
          style: theme.typography.interface(color: theme.colors.inkMuted),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final root = _root;
    final trail = [
      for (final id in _path)
        (
          id: id,
          name: _all.where((node) => node.id == id).firstOrNull?.name ?? '',
        ),
    ];
    final items = _items;
    final undo = _undo;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final page = Padding(
          padding: EdgeInsets.all(switch (width) {
            >= 1024 => Spacing.d32,
            >= 640 => Spacing.d24,
            _ => Spacing.d16,
          }),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d24,
            children: [
              _header(theme, width >= 640),
              Folder(
                value: root.id,
                onValueChange: (value) => setState(() {
                  _rootId = value;
                  _reset();
                }),
                maxWidth: double.infinity,
                children: [
                  FolderTabs(
                    semanticLabel: 'Places',
                    children: [
                      for (final drawer in fileExplorerRoots)
                        switch (width >= 640) {
                          true => FolderTab(
                            value: drawer.id,
                            child: Text(drawer.name),
                          ),
                          false => Expanded(
                            child: FolderTab(
                              value: drawer.id,
                              child: Text(
                                drawer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.interface(cssSize: 14),
                              ),
                            ),
                          ),
                        },
                    ],
                  ),
                  for (final drawer in fileExplorerRoots)
                    FolderContent(
                      value: drawer.id,
                      child: FileExplorerBrowser(
                        rootName: drawer.name,
                        trail: trail,
                        items: items,
                        view: _view,
                        onView: (view) => setState(() => _view = view),
                        sort: _sort,
                        onSort: (sort) => setState(() => _sort = sort),
                        search: _search,
                        selected: _selected,
                        onSelect: (id, on) => setState(() {
                          _selected = switch (on) {
                            true => {..._selected, id},
                            false => {..._selected}..remove(id),
                          };
                        }),
                        onSelectAll: (on) => setState(() {
                          _selected = switch (on) {
                            true => {for (final item in items) item.id},
                            false => {},
                          };
                        }),
                        onClearSelection: () => setState(() => _selected = {}),
                        onActivate: _activate,
                        onDelete: (item) =>
                            _remove([item.id], '“${item.name}”'),
                        onDeleteSelected: () => _remove(
                          _selected,
                          '${_selected.length} ${switch (_selected.length) {
                            1 => 'item',
                            _ => 'items',
                          }}',
                        ),
                        onNewFolder: _newFolder,
                        onCrumb: (depth) => _go(_path.sublist(0, depth)),
                        undo: undo?.text,
                        onUndo: _undoDelete,
                        empty: _inside.isEmpty,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Stack(
              children: [
                page,
                Semantics(
                  liveRegion: true,
                  label: _message,
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
