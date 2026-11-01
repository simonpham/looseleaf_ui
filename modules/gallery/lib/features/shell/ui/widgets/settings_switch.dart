import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A labelled on/off row in the display settings popover.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Label(child: Text(label))),
      Switch(value: value, onChanged: onChanged, semanticLabel: label),
    ],
  );
}
