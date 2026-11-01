import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SwitchDemoExample extends StatefulWidget {
  const SwitchDemoExample({super.key});

  @override
  State<SwitchDemoExample> createState() => _SwitchDemoExampleState();
}

class _SwitchDemoExampleState extends State<SwitchDemoExample> {
  bool _airplaneMode = false;

  @override
  Widget build(BuildContext context) => Switch(
    value: _airplaneMode,
    onChanged: (value) => setState(() => _airplaneMode = value),
    label: const Text('Airplane Mode'),
  );
}
