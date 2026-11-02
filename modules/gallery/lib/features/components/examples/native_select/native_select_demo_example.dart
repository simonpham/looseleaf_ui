import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectDemoExample extends StatefulWidget {
  const NativeSelectDemoExample({super.key});

  @override
  State<NativeSelectDemoExample> createState() =>
      _NativeSelectDemoExampleState();
}

class _NativeSelectDemoExampleState extends State<NativeSelectDemoExample> {
  String? _value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d320),
    child: NativeSelect<String>(
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      placeholder: 'Select status',
      semanticLabel: 'Status',
      options: const [
        NativeSelectOption(value: 'todo', label: 'Todo'),
        NativeSelectOption(value: 'in-progress', label: 'In Progress'),
        NativeSelectOption(value: 'done', label: 'Done'),
        NativeSelectOption(value: 'canceled', label: 'Canceled'),
      ],
    ),
  );
}
