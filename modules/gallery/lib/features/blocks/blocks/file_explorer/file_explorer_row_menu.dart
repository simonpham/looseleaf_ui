import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A file's ellipsis menu: open (or pick) it, or delete it.
class FileExplorerRowMenu extends StatelessWidget {
  const FileExplorerRowMenu({
    super.key,
    required this.item,
    required this.onActivate,
    required this.onDelete,
  });

  final FileExplorerItem item;
  final ValueChanged<FileExplorerItem> onActivate;
  final ValueChanged<FileExplorerItem> onDelete;

  static const double _width = 160;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DropdownMenu(
      content: DropdownMenuContent(
        align: OverlayAlign.end,
        minWidth: _width,
        children: [
          DropdownMenuItem(
            leading: InkIcon(switch (item.isFolder) {
              true => 'folder-open',
              false => 'check',
            }),
            onSelect: () => onActivate(item),
            child: Text(switch (item.isFolder) {
              true => 'Open',
              false => 'Pick',
            }),
          ),
          const DropdownMenuSeparator(),
          DropdownMenuItem(
            variant: InkMenuItemVariant.destructive,
            leading: const InkIcon('trash'),
            onSelect: () => onDelete(item),
            child: const Text('Delete'),
          ),
        ],
      ),
      child: DropdownMenuTrigger.builder(
        builder: (context, menu) => Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.icon,
          semanticLabel: 'Actions for ${item.name}',
          onPressed: menu.toggle,
          child: InkIcon('ellipsis-vertical', color: theme.colors.inkMuted),
        ),
      ),
    );
  }
}
