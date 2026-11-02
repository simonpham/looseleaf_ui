import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PageDefaultExample extends StatelessWidget {
  const PageDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => PaperPage(
    seed: 'field-notes',
    children: [
      const PageHeader(
        children: [
          PageTitle(Text('Field notes')),
          PageDescription(
            Text(
              'A week of small observations, written where the light was good.',
            ),
          ),
        ],
      ),
      PageContent(
        children: [
          const Text(
            'Most of what I remember from a book is in the margins: an arrow, a question mark, a small argument with a dead author. The rest is weather.',
          ),
          const Text(
            'Tuesday. Rain on the window, three cups of tea, and one very small plan for a very big week.',
          ),
          Button(onPressed: () {}, child: const Text('Save the page')),
        ],
      ),
      const PageFooter(
        children: [
          Text('Draft'),
          Text(
            '- 3 -',
            style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    ],
  );
}
