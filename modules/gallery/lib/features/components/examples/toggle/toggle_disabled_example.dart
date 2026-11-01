import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleDisabledExample extends StatelessWidget {
  const ToggleDisabledExample({super.key});

  @override
  Widget build(BuildContext context) => const Toggle(
    value: false,
    disabled: true,
    semanticLabel: 'Toggle underline',
    child: InkIcon('underline'),
  );
}
