import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _cards = [
  (q: 'petrichor', a: 'the smell of rain on dry earth'),
  (
    q: 'sonder',
    a: 'the realisation that everyone has a life as vivid as yours',
  ),
  (q: 'komorebi', a: 'sunlight filtering through leaves'),
];

class IndexCardFlashcardsExample extends StatefulWidget {
  const IndexCardFlashcardsExample({super.key});

  @override
  State<IndexCardFlashcardsExample> createState() =>
      _IndexCardFlashcardsExampleState();
}

class _IndexCardFlashcardsExampleState
    extends State<IndexCardFlashcardsExample> {
  static const _maxWidth = 448.0;

  int _index = 0;
  bool _shown = false;

  void _next() => setState(() {
    _index += 1;
    _shown = false;
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final card = _cards[_index];
    final left = _cards.length - _index - 1;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          spacing: Spacing.d32,
          children: [
            Semantics(
              liveRegion: true,
              child: IndexCard(
                hole: true,
                flag: switch (_shown) {
                  true => Accent.grass,
                  false => null,
                },
                stack: math.min(3, left),
                seed: 'card-$_index',
                minHeight: 254,
                children: [
                  IndexCardHeader(children: [IndexCardTitle(Text(card.q))]),
                  IndexCardContent(
                    children: [
                      switch (_shown) {
                        true => Text(card.a),
                        false => Text(
                          'what does it mean?',
                          style: TextStyle(color: theme.colors.inkMuted),
                        ),
                      },
                    ],
                  ),
                  IndexCardFooter(
                    children: [
                      Text(
                        '${_index + 1} of ${_cards.length}',
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d12,
              children: [
                Button(
                  variant: ButtonVariant.secondary,
                  onPressed: () => setState(() => _shown = !_shown),
                  child: Text(switch (_shown) {
                    true => 'Hide',
                    false => 'Show the answer',
                  }),
                ),
                Button(
                  disabled: _index == _cards.length - 1,
                  onPressed: _next,
                  child: const Text('Next card'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
