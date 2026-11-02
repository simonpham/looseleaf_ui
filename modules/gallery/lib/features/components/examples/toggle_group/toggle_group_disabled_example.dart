import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupDisabledExample extends StatefulWidget {
  const ToggleGroupDisabledExample({super.key});

  @override
  State<ToggleGroupDisabledExample> createState() =>
      _ToggleGroupDisabledExampleState();
}

class _ToggleGroupDisabledExampleState
    extends State<ToggleGroupDisabledExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
    type: ToggleGroupType.multiple,
    disabled: true,
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
