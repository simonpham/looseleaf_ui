import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleWithTextExample extends StatelessWidget {
  const ToggleWithTextExample({super.key});

  @override
  Widget build(BuildContext context) => const Toggle(
    leading: InkIcon('italic'),
    child: Text('Italic'),
  );
}
