import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PageWeeklyReviewExample extends StatefulWidget {
  const PageWeeklyReviewExample({super.key});

  @override
  State<PageWeeklyReviewExample> createState() =>
      _PageWeeklyReviewExampleState();
}

class _PageWeeklyReviewExampleState extends State<PageWeeklyReviewExample> {
  static const _done = [
    'Ink the outline',
    'Wash the sky, then wait',
    'Hatch the shade',
  ];

  final _checked = [true, true, false];
  final _note = FocusNode();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Weekly review',
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        PaperPage(
          holes: PageHoles.start,
          reinforced: true,
          seed: 'review',
          children: [
            const PageHeader(
              children: [
                PageTitle(Text('Weekly review')),
                PageDescription(
                  Text(
                    'What got finished, what did not, and one thing to try on Monday.',
                  ),
                ),
              ],
            ),
            PageContent(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: Spacing.d8),
                      child: Text(
                        'Finished',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    for (final (i, item) in _done.indexed)
                      Checkbox(
                        value: _checked[i],
                        onChanged: (value) =>
                            setState(() => _checked[i] = value),
                        label: Text(item),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d8,
                  children: [
                    Label(
                      focusNode: _note,
                      child: const Text('One thing for Monday'),
                    ),
                    Textarea(
                      focusNode: _note,
                      ruled: true,
                      placeholder: 'Start with the sky.',
                      semanticLabel: 'One thing for Monday',
                    ),
                  ],
                ),
              ],
            ),
            PageFooter(
              children: [
                const Text(
                  'week 39',
                  style: TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Button(onPressed: () {}, child: const Text('File it')),
              ],
            ),
          ],
        ),
        const PositionedDirectional(
          top: -Spacing.d20,
          end: -Spacing.d12,
          child: Sticker('done', size: 72, rotate: 8),
        ),
      ],
    ),
  );
}
