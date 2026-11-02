import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxResponsiveExample extends StatefulWidget {
  const ComboboxResponsiveExample({super.key});

  @override
  State<ComboboxResponsiveExample> createState() =>
      _ComboboxResponsiveExampleState();
}

class _ComboboxResponsiveExampleState extends State<ComboboxResponsiveExample> {
  static const double _desktopFrom = 768;

  bool _open = false;
  String? _selected;

  void _pick(String status) => setState(() {
    _selected = status;
    _open = false;
  });

  Widget _trigger(VoidCallback toggle) => SizedBox(
    width: Spacing.d128 + Spacing.d22,
    child: Semantics(
      expanded: _open,
      child: Button(
        variant: ButtonVariant.outline,
        semanticLabel: 'Status',
        onPressed: toggle,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(_selected ?? '+ Set status'),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= _desktopFrom;
    if (isDesktop) {
      return Popover(
        open: _open,
        onOpenChange: (open) => setState(() => _open = open),
        content: PopoverContent(
          align: OverlayAlign.start,
          width: Spacing.d176 + Spacing.d32,
          padding: EdgeInsets.zero,
          semanticLabel: 'Set status',
          child: _StatusList(onPick: _pick),
        ),
        child: PopoverTrigger.builder(
          builder: (context, popover) => _trigger(popover.toggle),
        ),
      );
    }
    return Drawer(
      open: _open,
      onOpenChange: (open) => setState(() => _open = open),
      content: DrawerContent(
        seed: 'status',
        semanticLabel: 'Set status',
        children: [
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Separator(variant: SeparatorVariant.dashed),
                _StatusList(onPick: _pick),
              ],
            ),
          ),
        ],
      ),
      child: DrawerTrigger.builder(
        builder: (context, drawer) => _trigger(drawer.toggle),
      ),
    );
  }
}

class _StatusList extends StatelessWidget {
  const _StatusList({required this.onPick});

  static const _statuses = [
    (value: 'backlog', label: 'Backlog'),
    (value: 'todo', label: 'Todo'),
    (value: 'in progress', label: 'In progress'),
    (value: 'done', label: 'Done'),
    (value: 'canceled', label: 'Canceled'),
  ];

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Command(
    sheet: false,
    children: [
      const CommandInput(placeholder: 'Filter status...'),
      CommandList(
        children: [
          const CommandEmpty(child: Text('No results found.')),
          CommandGroup(
            children: [
              for (final status in _statuses)
                CommandItem(
                  value: status.value,
                  onSelect: (_) => onPick(status.label),
                  child: Text(status.label),
                ),
            ],
          ),
        ],
      ),
    ],
  );
}
