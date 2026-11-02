import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScribbleEditedDraftExample extends StatelessWidget {
  const ScribbleEditedDraftExample({super.key});

  static const _maxWidth = Spacing.d512;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        padding: const EdgeInsets.all(Spacing.d28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d12,
          children: [
            Text(
              'Draft 3',
              style: theme.typography.face(KevinSansFace.script, cssSize: 24),
            ),
            DefaultTextStyle.merge(
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 17,
                cssLineHeight: 1.7,
              ),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'The garden was '),
                    _Marked(
                      Scribble(
                        weight: MarkWeight.fine,
                        child: Text('very extremely'),
                      ),
                    ),
                    TextSpan(
                      text: ' overgrown, and the gate, which had been ',
                    ),
                    _Marked(Strike(child: Text('painted green'))),
                    TextSpan(text: ' left open for years, no longer '),
                    _Marked(
                      Scribble(
                        tone: MarkPen.red,
                        child: Text('closed properly at all'),
                      ),
                    ),
                    TextSpan(text: ' closed. '),
                    _Marked(
                      Highlight(
                        tone: HighlightTone.green,
                        child: Text('Keep this line.'),
                      ),
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

class _Marked extends WidgetSpan {
  const _Marked(Widget mark)
    : super(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: mark,
      );
}
