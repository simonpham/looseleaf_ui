import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleWithTextExample extends StatefulWidget {
  const ToggleWithTextExample({super.key});

  @override
  State<ToggleWithTextExample> createState() => _ToggleWithTextExampleState();
}

class _ToggleWithTextExampleState extends State<ToggleWithTextExample> {
  bool _italic = false;

  @override
  Widget build(BuildContext context) => Toggle(
    value: _italic,
    onChanged: (value) => setState(() => _italic = value),
    leading: const InkIcon('italic'),
    child: const Text('Italic'),
  );
}
