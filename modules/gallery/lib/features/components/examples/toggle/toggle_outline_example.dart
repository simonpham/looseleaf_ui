import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleOutlineExample extends StatefulWidget {
  const ToggleOutlineExample({super.key});

  @override
  State<ToggleOutlineExample> createState() => _ToggleOutlineExampleState();
}

class _ToggleOutlineExampleState extends State<ToggleOutlineExample> {
  bool _italic = false;

  @override
  Widget build(BuildContext context) => Toggle(
    value: _italic,
    onChanged: (value) => setState(() => _italic = value),
    variant: ToggleVariant.outline,
    semanticLabel: 'Toggle italic',
    child: const InkIcon('italic'),
  );
}
