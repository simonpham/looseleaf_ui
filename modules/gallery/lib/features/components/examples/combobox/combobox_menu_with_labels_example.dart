import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxMenuWithLabelsExample extends StatefulWidget {
  const ComboboxMenuWithLabelsExample({super.key});

  @override
  State<ComboboxMenuWithLabelsExample> createState() =>
      _ComboboxMenuWithLabelsExampleState();
}

class _ComboboxMenuWithLabelsExampleState
    extends State<ComboboxMenuWithLabelsExample> {
  static const _labels = [
    'feature',
    'bug',
    'enhancement',
    'documentation',
    'design',
    'question',
    'maintenance',
  ];

  String _label = 'feature';
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d128 * 4),
      child: Paper(
        seed: 'task-row',
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d16,
          vertical: Spacing.d8,
        ),
        child: Row(
          spacing: Spacing.d12,
          children: [
            Expanded(
              child: Row(
                spacing: Spacing.d12,
                children: [
                  Badge(child: Text(_label)),
                  Flexible(
                    child: Text(
                      'Create a new project',
                      style: TextStyle(color: theme.colors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenu(
              open: _open,
              onOpenChange: (open) => setState(() => _open = open),
              content: DropdownMenuContent(
                align: OverlayAlign.end,
                width: Spacing.d112 * 2,
                seed: 'task-actions',
                children: [
                  const DropdownMenuLabel(child: Text('Actions')),
                  DropdownMenuGroup(
                    children: [
                      const DropdownMenuItem(child: Text('Assign to...')),
                      const DropdownMenuItem(child: Text('Set due date...')),
                      const DropdownMenuSeparator(),
                      DropdownMenuSub(
                        trigger: const DropdownMenuSubTrigger(
                          child: Text('Apply label'),
                        ),
                        content: DropdownMenuSubContent(
                          children: [
                            Command(
                              sheet: false,
                              semanticLabel: 'Labels',
                              children: [
                                const CommandInput(
                                  placeholder: 'Filter label...',
                                ),
                                CommandList(
                                  children: [
                                    const CommandEmpty(
                                      child: Text('No label found.'),
                                    ),
                                    CommandGroup(
                                      children: [
                                        for (final label in _labels)
                                          CommandItem(
                                            value: label,
                                            onSelect: (_) => setState(() {
                                              _label = label;
                                              _open = false;
                                            }),
                                            child: Text(label),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const DropdownMenuSeparator(),
                      const DropdownMenuItem(
                        variant: InkMenuItemVariant.destructive,
                        trailing: DropdownMenuShortcut('⌘⌫'),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              child: DropdownMenuTrigger.builder(
                builder: (context, menu) => Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.iconSm,
                  semanticLabel: 'Task actions',
                  onPressed: menu.toggle,
                  child: const InkIcon('ellipsis'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
