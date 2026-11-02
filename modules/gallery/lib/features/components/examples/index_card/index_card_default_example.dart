import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class IndexCardDefaultExample extends StatelessWidget {
  const IndexCardDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const IndexCard(
    seed: 'recipes',
    children: [
      IndexCardHeader(children: [IndexCardTitle(Text('Recipes'))]),
      IndexCardContent(
        children: [
          Text('oat porridge, the slow way'),
          Text('soup that forgives'),
          Text('toast, honestly'),
        ],
      ),
      IndexCardFooter(
        children: [
          Text(
            'no. 0042',
            style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
          Text(
            'p. 3',
            style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    ],
  );
}
