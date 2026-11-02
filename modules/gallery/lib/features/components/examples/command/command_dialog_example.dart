import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CommandDialogExample extends StatefulWidget {
  const CommandDialogExample({super.key});

  @override
  State<CommandDialogExample> createState() => _CommandDialogExampleState();
}

class _CommandDialogExampleState extends State<CommandDialogExample> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.keyK) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isMetaPressed && !keyboard.isControlPressed) return false;
    setState(() => _open = !_open);
    return true;
  }

  void _setOpen(bool open) => setState(() => _open = open);

  void _run(String value) => _setOpen(false);

  @override
  Widget build(BuildContext context) => CommandDialog(
    open: _open,
    onOpenChange: _setOpen,
    title: 'Search the notebook',
    description: 'Jump to a page or run a command',
    children: [
      const CommandInput(placeholder: 'Jump to a page or run a command...'),
      CommandList(
        children: [
          const CommandEmpty(child: Text('Nothing on that page.')),
          CommandGroup(
            heading: const Text('Pages'),
            children: [
              CommandItem(
                onSelect: _run,
                leading: const InkIcon('file-text'),
                child: const Text('Field notes'),
              ),
              CommandItem(
                onSelect: _run,
                leading: const InkIcon('book-open'),
                child: const Text('Recipes'),
              ),
              CommandItem(
                onSelect: _run,
                leading: const InkIcon('folder'),
                child: const Text('Garden log'),
              ),
            ],
          ),
          const CommandSeparator(),
          CommandGroup(
            heading: const Text('Actions'),
            children: [
              CommandItem(
                onSelect: _run,
                leading: const InkIcon('plus'),
                trailing: const CommandShortcut('Ctrl N'),
                child: const Text('New page'),
              ),
              CommandItem(
                onSelect: _run,
                leading: const InkIcon('copy'),
                trailing: const CommandShortcut('Ctrl D'),
                child: const Text('Duplicate page'),
              ),
              CommandItem(
                onSelect: _run,
                disabled: true,
                leading: const InkIcon('trash'),
                child: const Text('Empty the bin'),
              ),
            ],
          ),
        ],
      ),
    ],
    child: Button(
      variant: ButtonVariant.outline,
      onPressed: () => _setOpen(true),
      leading: const InkIcon('search'),
      trailing: const KbdGroup(
        children: [
          Kbd(child: Text('Ctrl')),
          Kbd(child: Text('K')),
        ],
      ),
      child: const Text('Search the notebook'),
    ),
  );
}
