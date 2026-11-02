import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupOutlineExample extends StatefulWidget {
  const ToggleGroupOutlineExample({super.key});

  @override
  State<ToggleGroupOutlineExample> createState() =>
      _ToggleGroupOutlineExampleState();
}

class _ToggleGroupOutlineExampleState extends State<ToggleGroupOutlineExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
    type: ToggleGroupType.multiple,
    variant: ToggleVariant.outline,
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    semanticLabel: 'Text formatting',
    children: const [
      ToggleGroupItem(
        value: 'bold',
        semanticLabel: 'Toggle bold',
        child: InkIcon('bold'),
      ),
      ToggleGroupItem(
        value: 'italic',
        semanticLabel: 'Toggle italic',
        child: InkIcon('italic'),
      ),
      ToggleGroupItem(
        value: 'underline',
        semanticLabel: 'Toggle underline',
        child: InkIcon('underline'),
      ),
    ],
  );
}
