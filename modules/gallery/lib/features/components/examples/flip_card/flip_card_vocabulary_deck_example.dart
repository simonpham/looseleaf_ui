import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FlipCardVocabularyDeckExample extends StatefulWidget {
  const FlipCardVocabularyDeckExample({super.key});

  @override
  State<FlipCardVocabularyDeckExample> createState() =>
      _FlipCardVocabularyDeckExampleState();
}

class _FlipCardVocabularyDeckExampleState
    extends State<FlipCardVocabularyDeckExample> {
  static const _deck = [
    (word: 'la maison', meaning: 'the house'),
    (word: 'le chat', meaning: 'the cat'),
    (word: "l'encre", meaning: 'the ink'),
    (word: 'le crayon', meaning: 'the pencil'),
  ];

  int _index = 0;
  bool _flipped = false;

  void _go(int step) => setState(() {
    _flipped = false;
    _index = (_index + step + _deck.length) % _deck.length;
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final card = _deck[_index];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d16,
        children: [
          FlipCard(
            flipped: _flipped,
            onFlippedChange: (flipped) => setState(() => _flipped = flipped),
            label: switch (_flipped) {
              true => 'Show the word',
              false => 'Show the answer',
            },
            children: [
              FlipCardFront(
                textSize: 36,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -Spacing.d9),
                    child: Text(card.word),
                  ),
                ],
              ),
              FlipCardBack(textSize: 36, children: [Text(card.meaning)]),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d12,
            children: [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => _go(-1),
                child: const Text('Back'),
              ),
              Text(
                '${_index + 1} of ${_deck.length}',
                style: theme.typography
                    .interface(cssSize: 14)
                    .copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              Button(
                size: ButtonSize.sm,
                onPressed: () => _go(1),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
