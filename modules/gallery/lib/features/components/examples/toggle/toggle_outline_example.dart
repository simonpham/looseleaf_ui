import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleOutlineExample extends StatelessWidget {
  const ToggleOutlineExample({super.key});

  @override
  Widget build(BuildContext context) => const Toggle(
    variant: ToggleVariant.outline,
    semanticLabel: 'Toggle italic',
    child: InkIcon('italic'),
  );
}
