import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

WidgetSpan _mark(Highlight highlight) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: highlight,
);

class HighlightReadingNotesExample extends StatelessWidget {
  const HighlightReadingNotesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          tape: PaperTape.top,
          children: [
            CardHeader(
              children: [
                CardTitle(
                  Text(
                    'Notes on Walden, ch. 2',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                    ),
                  ),
                ),
                const CardDescription(Text('Read on the train, 14 March')),
              ],
            ),
            CardContent(
              child: DefaultTextStyle.merge(
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 17,
                  cssLineHeight: 1.55,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d12,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                '“I went to the woods because I wished to '
                                'live deliberately,” and then, a page later, ',
                          ),
                          _mark(
                            const Highlight(
                              child: Text(
                                'to front only the essential facts of life',
                              ),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'The part I keep coming back to is ',
                          ),
                          _mark(
                            const Highlight(
                              tone: HighlightTone.green,
                              child: Text(
                                'simplicity, simplicity, simplicity',
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ': he says it three times, as if the first '
                                'two were not enough.',
                          ),
                        ],
                      ),
                    ),
                    const Highlight(
                      tone: HighlightTone.pink,
                      weight: HighlightWeight.light,
                      child: Text('Ask Sam what she thinks about the pond.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
