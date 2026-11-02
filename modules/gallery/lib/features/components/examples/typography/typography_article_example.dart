import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypographyArticleExample extends StatelessWidget {
  const TypographyArticleExample({super.key});

  static const _maxWidth = 672.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Paper(
      seed: 'article',
      padding: EdgeInsets.all(Spacing.d36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Muted(child: Text('Notebook / 4 min read')),
          SizedBox(height: Spacing.d4),
          H1(child: Text('Why the margin is the best part')),
          SizedBox(height: Spacing.d16),
          Lead(
            child: Text(
              'A book is a conversation with someone who cannot answer back.',
            ),
          ),
          SizedBox(height: Spacing.d24),
          P(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'So you answer in the margin: '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Annotate(
                      type: AnnotateType.highlight,
                      child: Text(
                        'an arrow, a question mark, a small argument',
                      ),
                    ),
                  ),
                  TextSpan(text: '. Keep the pencil close and the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InlineCode('rules'),
                  ),
                  TextSpan(text: ' loose.'),
                ],
              ),
            ),
          ),
          SizedBox(height: Spacing.d32),
          H2(child: Text('Three habits')),
          SizedBox(height: Spacing.d16),
          TypographyList(
            children: [
              Text('Date every page'),
              Text('Never erase; cross out'),
              Text('Leave a line at the end for what you want to ask next'),
            ],
          ),
          SizedBox(height: Spacing.d24),
          Blockquote(child: Text('Write it down before you lose it.')),
        ],
      ),
    ),
  );
}
