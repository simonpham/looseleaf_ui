import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuRadioGroupExample extends StatefulWidget {
  const DropdownMenuRadioGroupExample({super.key});

  @override
  State<DropdownMenuRadioGroupExample> createState() =>
      _DropdownMenuRadioGroupExampleState();
}

class _DropdownMenuRadioGroupExampleState
    extends State<DropdownMenuRadioGroupExample> {
  static const _width = 224.0;

  String _position = 'bottom';

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      minWidth: _width,
      children: [
        const DropdownMenuLabel(child: Text('Panel Position')),
        const DropdownMenuSeparator(),
        DropdownMenuRadioGroup(
          value: _position,
          onChanged: (value) => setState(() => _position = value),
          children: const [
            DropdownMenuRadioItem(value: 'top', child: Text('Top')),
            DropdownMenuRadioItem(value: 'bottom', child: Text('Bottom')),
            DropdownMenuRadioItem(value: 'right', child: Text('Right')),
          ],
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
