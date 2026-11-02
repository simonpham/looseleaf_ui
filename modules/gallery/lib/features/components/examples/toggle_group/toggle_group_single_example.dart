import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupSingleExample extends StatefulWidget {
  const ToggleGroupSingleExample({super.key});

  @override
  State<ToggleGroupSingleExample> createState() =>
      _ToggleGroupSingleExampleState();
}

class _ToggleGroupSingleExampleState extends State<ToggleGroupSingleExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) => ToggleGroup<String>(
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
