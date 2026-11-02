import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypographyScaleExample extends StatelessWidget {
  const TypographyScaleExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      H1(child: Text('Notes on keeping a notebook')),
      SizedBox(height: Spacing.d16),
      Lead(
        child: Text(
          'A notebook is a small argument you have with yourself, one page at a time.',
        ),
      ),
      SizedBox(height: Spacing.d24),
      P(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Most of what I remember from a book is in the margins. Run ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: InlineCode('npm run notes'),
              ),
              TextSpan(text: ' if you want it on the screen.'),
            ],
          ),
        ),
      ),
      SizedBox(height: Spacing.d32),
      H2(child: Text('What goes in the margin')),
      SizedBox(height: Spacing.d16),
      TypographyList(
        children: [
          Text('A question you cannot answer yet'),
          Text('A disagreement, politely worded'),
        ],
      ),
      SizedBox(height: Spacing.d24),
      H3(child: Text('A word from someone who knew')),
      SizedBox(height: Spacing.d24),
      Blockquote(
        child: Text('The best time to write it down was when it happened.'),
      ),
      SizedBox(height: Spacing.d24),
      H4(child: Text('Small print')),
      SizedBox(height: Spacing.d4),
      Wrap(
        spacing: Spacing.d24,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Large(child: Text('Large')),
          Small(child: Text('Small')),
          Muted(child: Text('Muted, for captions')),
        ],
      ),
    ],
  );
}
