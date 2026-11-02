import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FlipCardDefaultExample extends StatelessWidget {
  const FlipCardDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final note = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.pencilText,
    );
    return FlipCard(
      label: 'Show the answer',
      children: [
        FlipCardFront(
          textSize: 36,
          children: [
            const Text('le chat'),
            Text('(masculine noun)', style: note),
          ],
        ),
        FlipCardBack(
          textSize: 36,
          children: [
            const Text('the cat'),
            Text('purrs, ignores you', style: note),
          ],
        ),
      ],
    );
  }
}
