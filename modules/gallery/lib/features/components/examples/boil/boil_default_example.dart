import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BoilDefaultExample extends StatelessWidget {
  const BoilDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    spacing: Spacing.d24,
    children: [
      for (final name in const ['sun', 'flower', 'star', 'mushroom'])
        Boil(
          builder: (context, frame, seed) =>
              Doodle(name, size: Spacing.d96, seed: seed(name)),
        ),
    ],
  );
}
