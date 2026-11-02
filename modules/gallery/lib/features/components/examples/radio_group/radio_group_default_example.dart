import 'package:flutter/widgets.dart' hide RadioGroup;
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
  Widget build(BuildContext context) => RadioGroup<String>(
    value: _density,
    onChanged: (value) => setState(() => _density = value),
    semanticLabel: 'Density',
    children: const [
      RadioGroupItem(value: 'default', label: Text('Default')),
      RadioGroupItem(value: 'comfortable', label: Text('Comfortable')),
      RadioGroupItem(value: 'compact', label: Text('Compact')),
    ],
  );
}
