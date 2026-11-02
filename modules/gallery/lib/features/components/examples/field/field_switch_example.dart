import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldSwitchExample extends StatefulWidget {
  const FieldSwitchExample({super.key});

  @override
  State<FieldSwitchExample> createState() => _FieldSwitchExampleState();
}

class _FieldSwitchExampleState extends State<FieldSwitchExample> {
  static const _maxWidth = Spacing.d448;

  var _enabled = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Field(
      orientation: FieldOrientation.horizontal,
      children: [
        FieldContent(
          children: [
            FieldLabel(
              onPressed: () => setState(() => _enabled = !_enabled),
              child: const Text('Multi-factor authentication'),
            ),
            const FieldDescription(
              Text(
                'Enable multi-factor authentication. If you do not have a two-factor device, you can use a one-time code sent to your email.',
              ),
            ),
          ],
        ),
        Switch(
          value: _enabled,
          onChanged: (value) => setState(() => _enabled = value),
        ),
      ],
    ),
  );
}
