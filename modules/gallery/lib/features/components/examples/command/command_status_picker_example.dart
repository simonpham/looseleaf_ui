import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CommandStatusPickerExample extends StatefulWidget {
  const CommandStatusPickerExample({super.key});

  @override
  State<CommandStatusPickerExample> createState() =>
      _CommandStatusPickerExampleState();
}

class _CommandStatusPickerExampleState
    extends State<CommandStatusPickerExample> {
  static const _triggerWidth = 144.0;
  static const _contentWidth = 208.0;
  static const _statuses = [
    (value: 'backlog', label: 'Backlog'),
    (value: 'todo', label: 'To do'),
    (value: 'in-progress', label: 'In progress'),
    (value: 'done', label: 'Done'),
    (value: 'canceled', label: 'Canceled'),
  ];

  bool _open = false;
  String _status = 'todo';

  void _choose(String status) => setState(() {
    _status = status;
    _open = false;
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final current = _statuses.where((status) => status.value == _status);
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d12,
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
              width: _contentWidth,
              align: OverlayAlign.start,
              padding: EdgeInsets.zero,
              semanticLabel: 'Status',
              child: Command(
                children: [
                  const CommandInput(placeholder: 'Change status...'),
                  CommandList(
                    children: [
                      CommandGroup(
                        children: [
                          for (final status in _statuses)
                            CommandItem(
                              key: ValueKey(status.value),
                              value: status.label,
                              onSelect: (_) => _choose(status.value),
                              trailing: switch (status.value == _status) {
                                true => InkIcon(
                                  'check',
                                  color: theme.colors.inkYou,
                                ),
                                false => null,
                              },
                              child: Text(status.label),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            child: SizedBox(
              width: _triggerWidth,
              child: Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                semanticLabel: 'Change status',
                onPressed: () => setState(() => _open = !_open),
                trailing: const InkIcon('chevrons-up-down'),
                child: Text(current.firstOrNull?.label ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
