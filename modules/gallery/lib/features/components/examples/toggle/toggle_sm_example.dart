import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleSmExample extends StatefulWidget {
  const ToggleSmExample({super.key});

  @override
  State<ToggleSmExample> createState() => _ToggleSmExampleState();
}

class _ToggleSmExampleState extends State<ToggleSmExample> {
  bool _italic = false;

  @override
  Widget build(BuildContext context) => Toggle(
    value: _italic,
    onChanged: (value) => setState(() => _italic = value),
    size: ToggleSize.sm,
    semanticLabel: 'Toggle italic',
    child: const InkIcon('italic'),
  );
}
