import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleLgExample extends StatelessWidget {
  const ToggleLgExample({super.key});

  @override
  Widget build(BuildContext context) => const Toggle(
    size: ToggleSize.lg,
    semanticLabel: 'Toggle italic',
    child: InkIcon('italic'),
  );
}
