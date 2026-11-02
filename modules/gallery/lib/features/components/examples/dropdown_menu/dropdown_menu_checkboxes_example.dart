import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuCheckboxesExample extends StatefulWidget {
  const DropdownMenuCheckboxesExample({super.key});

  @override
  State<DropdownMenuCheckboxesExample> createState() =>
      _DropdownMenuCheckboxesExampleState();
}

class _DropdownMenuCheckboxesExampleState
    extends State<DropdownMenuCheckboxesExample> {
  static const _width = 224.0;

  bool _showStatusBar = true;
  bool _showActivityBar = false;
  bool _showPanel = false;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      minWidth: _width,
      children: [
        const DropdownMenuLabel(child: Text('Appearance')),
        const DropdownMenuSeparator(),
        DropdownMenuCheckboxItem(
          value: _showStatusBar,
          onChanged: (value) => setState(() => _showStatusBar = value),
          closeOnSelect: false,
          child: const Text('Status Bar'),
        ),
        DropdownMenuCheckboxItem(
          value: _showActivityBar,
          onChanged: (value) => setState(() => _showActivityBar = value),
          closeOnSelect: false,
          disabled: true,
          child: const Text('Activity Bar'),
        ),
        DropdownMenuCheckboxItem(
          value: _showPanel,
          onChanged: (value) => setState(() => _showPanel = value),
          closeOnSelect: false,
          child: const Text('Panel'),
        ),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => Button(
        variant: ButtonVariant.outline,
        onPressed: menu.toggle,
        child: const Text('Open'),
      ),
    ),
  );
}
