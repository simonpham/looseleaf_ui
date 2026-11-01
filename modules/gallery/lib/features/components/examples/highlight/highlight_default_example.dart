import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class HighlightDefaultExample extends StatelessWidget {
  const HighlightDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Text.rich(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 1.55,
        ),
        const TextSpan(
          children: [
            TextSpan(
              text:
                  'Most of what I remember from a book is in the margins. '
                  'The good bits get ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Highlight(child: Text('a swipe of yellow')),
            ),
            TextSpan(text: ' so I can find them on the next read.'),
          ],
        ),
      ),
    );
  }
}
