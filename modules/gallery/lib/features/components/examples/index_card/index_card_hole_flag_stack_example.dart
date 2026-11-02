import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class IndexCardHoleFlagStackExample extends StatelessWidget {
  const IndexCardHoleFlagStackExample({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d8),
    child: Wrap(
      spacing: Spacing.d40,
      runSpacing: Spacing.d40,
      children: [
        IndexCard(
          hole: true,
          flag: Accent.tomato,
          stack: 3,
          seed: 'sources',
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Sources'))]),
            IndexCardContent(
              children: [
                Text('sketchbook, dip pen, ink'),
                Text('sage green, ochre, madder'),
              ],
            ),
          ],
        ),
        IndexCard(
          hole: true,
          flag: Accent.sky,
          seed: 'words',
          minHeight: 194,
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Words'))]),
            IndexCardContent(
              children: [
                Text('petrichor'),
                Text('the smell of rain on dry earth'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
