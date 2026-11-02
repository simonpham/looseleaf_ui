import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _stocks = [
  StockName.stickyYellow,
  StockName.indexCard,
  StockName.kraft,
  StockName.paper,
  StockName.stickyBlue,
  StockName.graph,
  StockName.stickyPink,
];

const _notes = [
  'Ink',
  'A good eraser',
  'Tape',
  'Index cards',
  'Washi (dots)',
  'A ruler',
  'Stamp pad',
];

class CarouselTallyExample extends StatelessWidget {
  const CarouselTallyExample({super.key});

  static const _maxWidth = 448 + 2 * Carousel.arrowRoom;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Carousel(
        semanticLabel: 'Shopping notes',
        seed: 'tally',
        itemFraction: 1 / 2,
        children: [
          CarouselContent(
            children: [
              for (final (index, note) in _notes.indexed)
                CarouselItem(
                  semanticLabel: '${index + 1} of ${_notes.length}',
                  child: Card(
                    seed: 'n$index',
                    padding: EdgeInsets.zero,
                    stock: _stocks[index % _stocks.length],
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Center(
                          child: Text(
                            note,
                            textAlign: TextAlign.center,
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 24,
                              cssLineHeight: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const CarouselPrevious(),
          const CarouselNext(),
          const CarouselDots(),
          Builder(
            builder: (context) {
              final carousel = Carousel.maybeOf(context);
              final current = (carousel?.selectedIndex ?? 0) + 1;
              final count = carousel?.snapCount ?? _notes.length;
              return Padding(
                padding: const EdgeInsets.only(top: Spacing.d12),
                child: ExcludeSemantics(
                  child: Text(
                    'Slide $current of $count',
                    textAlign: TextAlign.center,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
