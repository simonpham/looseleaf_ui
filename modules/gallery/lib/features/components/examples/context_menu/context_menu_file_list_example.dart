import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _files = [
  (name: 'Field notes.md', icon: 'file-text'),
  (name: 'Garden log.md', icon: 'file-text'),
  (name: 'Recipes', icon: 'folder'),
  (name: 'Sketches', icon: 'folder'),
];

class ContextMenuFileListExample extends StatefulWidget {
  const ContextMenuFileListExample({super.key});

  @override
  State<ContextMenuFileListExample> createState() =>
      _ContextMenuFileListExampleState();
}

class _ContextMenuFileListExampleState
    extends State<ContextMenuFileListExample> {
  static const _maxWidth = 384.0;

  String _picked = 'Right-click a row.';

  void _pick(String message) => setState(() => _picked = message);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        seed: 'files',
        padding: const EdgeInsets.all(Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notebooks',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.d12),
            for (final file in _files)
              ContextMenu(
                content: ContextMenuContent(
                  width: 208,
                  children: [
                    ContextMenuItem(
                      leading: const InkIcon('folder-open'),
                      onSelect: () => _pick('Opened ${file.name}'),
                      child: const Text('Open'),
                    ),
                    ContextMenuItem(
                      leading: const InkIcon('pencil'),
                      trailing: const ContextMenuShortcut('F2'),
                      onSelect: () => _pick('Renamed ${file.name}'),
                      child: const Text('Rename'),
                    ),
                    ContextMenuItem(
                      leading: const InkIcon('copy'),
                      trailing: const ContextMenuShortcut('⌘D'),
                      onSelect: () => _pick('Copied ${file.name}'),
                      child: const Text('Duplicate'),
                    ),
                    const ContextMenuSeparator(),
                    ContextMenuItem(
                      variant: InkMenuItemVariant.destructive,
                      leading: const InkIcon('trash'),
                      onSelect: () => _pick('Trashed ${file.name}'),
                      child: const Text('Move to trash'),
                    ),
                  ],
                ),
                child: ContextMenuTrigger(
                  child: Focus(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.d8,
                        vertical: Spacing.d6,
                      ),
                      child: Row(
                        spacing: Spacing.d10,
                        children: [
                          InkIcon(file.icon),
                          Expanded(child: Text(file.name)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: Spacing.d12),
            const Separator(variant: SeparatorVariant.dashed),
            const SizedBox(height: Spacing.d8),
            Semantics(
              liveRegion: true,
              child: Text(
                _picked,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
