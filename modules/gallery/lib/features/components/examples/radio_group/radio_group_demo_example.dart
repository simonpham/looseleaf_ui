import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupDemoExample extends StatefulWidget {
  const RadioGroupDemoExample({super.key});

  @override
  State<RadioGroupDemoExample> createState() => _RadioGroupDemoExampleState();
}

class _RadioGroupDemoExampleState extends State<RadioGroupDemoExample> {
  String _value = 'comfortable';

  @override
  Widget build(BuildContext context) => RadioGroup<String>(
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    children: const [
      RadioGroupItem(value: 'default', label: Text('Default')),
      RadioGroupItem(value: 'comfortable', label: Text('Comfortable')),
      RadioGroupItem(value: 'compact', label: Text('Compact')),
    ],
  );
}
