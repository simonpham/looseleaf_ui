import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupSmExample extends StatefulWidget {
  const ToggleGroupSmExample({super.key});

  @override
  State<ToggleGroupSmExample> createState() => _ToggleGroupSmExampleState();
}

class _ToggleGroupSmExampleState extends State<ToggleGroupSmExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
    size: ToggleSize.sm,
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
