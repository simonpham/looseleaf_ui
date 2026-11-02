import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectInvalidExample extends StatefulWidget {
  const NativeSelectInvalidExample({super.key});

  @override
  State<NativeSelectInvalidExample> createState() =>
      _NativeSelectInvalidExampleState();
}

class _NativeSelectInvalidExampleState
    extends State<NativeSelectInvalidExample> {
  String? _value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d160 * 2),
    child: NativeSelect<String>(
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      invalid: true,
      placeholder: 'Select role',
      semanticLabel: 'Role',
      options: const [
        NativeSelectOption(value: 'admin', label: 'Admin'),
        NativeSelectOption(value: 'editor', label: 'Editor'),
        NativeSelectOption(value: 'viewer', label: 'Viewer'),
        NativeSelectOption(value: 'guest', label: 'Guest'),
      ],
    ),
  );
}
