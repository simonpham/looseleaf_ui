import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectDisabledExample extends StatefulWidget {
  const NativeSelectDisabledExample({super.key});

  @override
  State<NativeSelectDisabledExample> createState() =>
      _NativeSelectDisabledExampleState();
}

class _NativeSelectDisabledExampleState
    extends State<NativeSelectDisabledExample> {
  String? _value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d160 * 2),
    child: NativeSelect<String>(
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      disabled: true,
      placeholder: 'Select priority',
      semanticLabel: 'Priority',
      options: const [
        NativeSelectOption(value: 'low', label: 'Low'),
        NativeSelectOption(value: 'medium', label: 'Medium'),
        NativeSelectOption(value: 'high', label: 'High'),
        NativeSelectOption(value: 'critical', label: 'Critical'),
      ],
    ),
  );
}
