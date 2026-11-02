import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FlipCardNotepadExample extends StatelessWidget {
  const FlipCardNotepadExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return FlipCard(
      axis: FlipCardAxis.x,
      width: Spacing.d256,
      height: 208,
      label: 'Turn the page',
      children: [
        FlipCardFront(
          stock: StockName.stickyYellow,
          textSize: 30,
          children: [
            const Text('pancakes'),
            Text(
              'turn me over for the recipe',
              style: theme.typography.interface(cssSize: 14),
            ),
          ],
        ),
        const FlipCardBack(
          stock: StockName.indexCard,
          crossAxisAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.left,
          textSize: 20,
          children: [
            Text('2 eggs, 200 g flour,'),
            Text('300 ml milk. Whisk, rest,'),
            Text('fry until it smells right.'),
          ],
        ),
      ],
    );
  }
}
