import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxDefaultExample extends StatefulWidget {
  const CheckboxDefaultExample({super.key});

  @override
  State<CheckboxDefaultExample> createState() => _CheckboxDefaultExampleState();
}

class _CheckboxDefaultExampleState extends State<CheckboxDefaultExample> {
  bool _terms = false;

  @override
  Widget build(BuildContext context) => Checkbox(
    value: _terms,
    onChanged: (value) => setState(() => _terms = value),
    label: const Text('Accept the terms and conditions'),
  );
}
