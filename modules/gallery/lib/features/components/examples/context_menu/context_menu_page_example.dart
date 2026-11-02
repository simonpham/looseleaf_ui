import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ContextMenuPageExample extends StatefulWidget {
  const ContextMenuPageExample({super.key});

  @override
  State<ContextMenuPageExample> createState() => _ContextMenuPageExampleState();
}

class _ContextMenuPageExampleState extends State<ContextMenuPageExample> {
  bool _bookmarks = true;
  bool _urls = false;
  String _person = 'pedro';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ContextMenu(
      content: ContextMenuContent(
        width: Spacing.d288,
        seed: 'ctx',
        children: [
          ContextMenuItem(
            inset: true,
            onSelect: () {},
            trailing: const ContextMenuShortcut('⌘['),
            child: const Text('Back'),
          ),
          const ContextMenuItem(
            inset: true,
            disabled: true,
            trailing: ContextMenuShortcut('⌘]'),
            child: Text('Forward'),
          ),
          ContextMenuItem(
            inset: true,
            onSelect: () {},
            trailing: const ContextMenuShortcut('⌘R'),
            child: const Text('Reload'),
          ),
          ContextMenuSub(
            trigger: const ContextMenuSubTrigger(
              inset: true,
              child: Text('More tools'),
            ),
            content: ContextMenuSubContent(
              width: 208,
              children: [
                ContextMenuItem(
                  onSelect: () {},
                  trailing: const ContextMenuShortcut('⌘S'),
                  child: const Text('Save page as…'),
                ),
                ContextMenuItem(
                  onSelect: () {},
                  child: const Text('Create shortcut…'),
                ),
                ContextMenuItem(
                  onSelect: () {},
                  child: const Text('Name window…'),
                ),
                const ContextMenuSeparator(),
                ContextMenuItem(
                  onSelect: () {},
                  child: const Text('Developer tools'),
                ),
                const ContextMenuSeparator(),
                ContextMenuItem(
                  variant: InkMenuItemVariant.destructive,
                  leading: const InkIcon('trash'),
                  onSelect: () {},
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
          const ContextMenuSeparator(),
          ContextMenuCheckboxItem(
            value: _bookmarks,
            onChanged: (value) => setState(() => _bookmarks = value),
            trailing: const ContextMenuShortcut('⇧⌘B'),
            child: const Text('Show bookmarks'),
          ),
          ContextMenuCheckboxItem(
            value: _urls,
            onChanged: (value) => setState(() => _urls = value),
            child: const Text('Show full URLs'),
          ),
          const ContextMenuSeparator(),
          ContextMenuRadioGroup(
            value: _person,
            onChanged: (value) => setState(() => _person = value),
            children: const [
              ContextMenuLabel(inset: true, child: Text('People')),
              ContextMenuRadioItem(value: 'pedro', child: Text('Pedro Duarte')),
              ContextMenuRadioItem(value: 'colm', child: Text('Colm Tuite')),
            ],
          ),
        ],
      ),
      child: ContextMenuTrigger(
        child: Focus(
          child: Semantics(
            label: 'Right click, or press the menu key',
            child: SizedBox(
              width: Spacing.d320,
              height: 176,
              child: Paper(
                stock: StockName.graph,
                seed: 'region',
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Right-click anywhere',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 24,
                        ),
                      ),
                      Text(
                        'long-press on touch',
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
