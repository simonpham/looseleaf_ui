import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupDemoExample extends StatefulWidget {
  const ToggleGroupDemoExample({super.key});

  @override
  State<ToggleGroupDemoExample> createState() => _ToggleGroupDemoExampleState();
}

class _ToggleGroupDemoExampleState extends State<ToggleGroupDemoExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
    variant: ToggleVariant.outline,
    type: ToggleGroupType.multiple,
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
