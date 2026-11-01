import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StampPresetsExample extends StatelessWidget {
  const StampPresetsExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Stamp(name: 'stamp-approved'),
      Stamp(name: 'stamp-draft'),
      Stamp(name: 'stamp-paid'),
      Stamp(name: 'stamp-urgent'),
    ],
  );
}
