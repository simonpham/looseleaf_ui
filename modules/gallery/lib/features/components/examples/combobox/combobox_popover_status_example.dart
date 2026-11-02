import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxPopoverStatusExample extends StatefulWidget {
  const ComboboxPopoverStatusExample({super.key});

  @override
  State<ComboboxPopoverStatusExample> createState() =>
      _ComboboxPopoverStatusExampleState();
}

class _ComboboxPopoverStatusExampleState
    extends State<ComboboxPopoverStatusExample> {
  static const _statuses = [
    (value: 'backlog', label: 'Backlog'),
    (value: 'todo', label: 'Todo'),
    (value: 'in progress', label: 'In progress'),
    (value: 'done', label: 'Done'),
    (value: 'canceled', label: 'Canceled'),
  ];

  bool _open = false;
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        Text(
          'Status',
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
        Popover(
          open: _open,
          onOpenChange: (open) => setState(() => _open = open),
          content: PopoverContent(
            side: OverlaySide.right,
            align: OverlayAlign.start,
            width: Spacing.d176 + Spacing.d32,
            padding: EdgeInsets.zero,
            semanticLabel: 'Set status',
            child: Command(
              children: [
                const CommandInput(placeholder: 'Change status...'),
                CommandList(
                  children: [
                    const CommandEmpty(child: Text('No results found.')),
                    CommandGroup(
                      children: [
                        for (final status in _statuses)
                          CommandItem(
                            value: status.value,
                            onSelect: (_) => setState(() {
                              _selected = status.label;
                              _open = false;
                            }),
                            child: Text(status.label),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: PopoverTrigger.builder(
            builder: (context, popover) => SizedBox(
              width: Spacing.d128 + Spacing.d22,
              child: Semantics(
                expanded: _open,
                child: Button(
                  variant: ButtonVariant.outline,
                  semanticLabel: 'Status',
                  onPressed: popover.toggle,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(_selected ?? '+ Set status'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
