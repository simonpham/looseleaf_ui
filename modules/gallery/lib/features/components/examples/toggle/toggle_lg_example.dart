import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleLgExample extends StatefulWidget {
  const ToggleLgExample({super.key});

  @override
  State<ToggleLgExample> createState() => _ToggleLgExampleState();
}

class _ToggleLgExampleState extends State<ToggleLgExample> {
  bool _italic = false;

  @override
  Widget build(BuildContext context) => Toggle(
    value: _italic,
    onChanged: (value) => setState(() => _italic = value),
    size: ToggleSize.lg,
    semanticLabel: 'Toggle italic',
    child: const InkIcon('italic'),
  );
}
