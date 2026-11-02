import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

WidgetSpan _mark(Highlight highlight) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: highlight,
);

class HighlightTonesExample extends StatelessWidget {
  const HighlightTonesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
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
                  _mark(const Highlight(child: Text('yellow'))),
                  const TextSpan(text: ', '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.pink,
                      child: Text('pink'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.green,
                      child: Text('green'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.blue,
                      child: Text('blue'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.orange,
                      child: Text('orange'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.lilac,
                      child: Text('lilac'),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  _mark(
                    const Highlight(
                      tone: HighlightTone.teal,
                      child: Text('teal'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'A '),
                  _mark(
                    const Highlight(
                      weight: HighlightWeight.light,
                      child: Text('light hand'),
                    ),
                  ),
                  const TextSpan(text: ', a '),
                  _mark(const Highlight(child: Text('regular one'))),
                  const TextSpan(text: ', and a '),
                  _mark(
                    const Highlight(
                      weight: HighlightWeight.heavy,
                      child: Text('heavy chisel tip'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Or run it '),
                  _mark(
                    const Highlight(
                      cover: HighlightCover.under,
                      tone: HighlightTone.green,
                      child: Text('under the line'),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  _mark(
                    const Highlight(
                      cover: HighlightCover.under,
                      tone: HighlightTone.pink,
                      child: Text('let the words breathe'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
