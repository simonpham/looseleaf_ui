import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupDefaultExample extends StatefulWidget {
  const RadioGroupDefaultExample({super.key});

  @override
  State<RadioGroupDefaultExample> createState() =>
      _RadioGroupDefaultExampleState();
}

class _RadioGroupDefaultExampleState extends State<RadioGroupDefaultExample> {
  String _density = 'comfortable';

  @override
  Widget build(BuildContext context) => InkRadioGroup<String>(
    value: _density,
    onChanged: (value) => setState(() => _density = value),
    semanticLabel: 'Density',
    children: const [
      InkRadioGroupItem(value: 'default', label: Text('Default')),
      InkRadioGroupItem(value: 'comfortable', label: Text('Comfortable')),
      InkRadioGroupItem(value: 'compact', label: Text('Compact')),
    ],
  );
}
