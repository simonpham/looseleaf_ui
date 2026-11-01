import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SwitchDefaultExample extends StatefulWidget {
  const SwitchDefaultExample({super.key});

  @override
  State<SwitchDefaultExample> createState() => _SwitchDefaultExampleState();
}

class _SwitchDefaultExampleState extends State<SwitchDefaultExample> {
  bool _airplane = false;

  @override
  Widget build(BuildContext context) => Switch(
    value: _airplane,
    onChanged: (value) => setState(() => _airplane = value),
    label: const Text('Airplane mode'),
  );
}
