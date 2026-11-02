import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleSmExample extends StatelessWidget {
  const ToggleSmExample({super.key});

  @override
  Widget build(BuildContext context) => const Toggle(
    size: ToggleSize.sm,
    semanticLabel: 'Toggle italic',
    child: InkIcon('italic'),
  );
}
