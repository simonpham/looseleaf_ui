import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupLgExample extends StatefulWidget {
  const ToggleGroupLgExample({super.key});

  @override
  State<ToggleGroupLgExample> createState() => _ToggleGroupLgExampleState();
}

class _ToggleGroupLgExampleState extends State<ToggleGroupLgExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
    type: ToggleGroupType.multiple,
    size: ToggleSize.lg,
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
