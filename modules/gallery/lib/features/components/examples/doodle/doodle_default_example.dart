import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DoodleDefaultExample extends StatelessWidget {
  const DoodleDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d24,
    runSpacing: Spacing.d24,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      Doodle('star'),
      Doodle('sun'),
      Doodle('flower'),
      Doodle('mushroom'),
    ],
  );
}
