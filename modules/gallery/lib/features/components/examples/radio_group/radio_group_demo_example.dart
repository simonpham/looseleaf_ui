import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupDemoExample extends StatefulWidget {
  const RadioGroupDemoExample({super.key});

  @override
  State<RadioGroupDemoExample> createState() => _RadioGroupDemoExampleState();
}

class _RadioGroupDemoExampleState extends State<RadioGroupDemoExample> {
  String _value = 'comfortable';

  @override
  Widget build(BuildContext context) => InkRadioGroup<String>(
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    children: const [
      InkRadioGroupItem(value: 'default', label: Text('Default')),
      InkRadioGroupItem(value: 'comfortable', label: Text('Comfortable')),
      InkRadioGroupItem(value: 'compact', label: Text('Compact')),
    ],
  );
}
