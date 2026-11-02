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

class CarouselTallyExample extends StatefulWidget {
  const CarouselTallyExample({super.key});

  @override
  State<CarouselTallyExample> createState() => _CarouselTallyExampleState();
}

class _CarouselTallyExampleState extends State<CarouselTallyExample> {
  static const _maxWidth = Spacing.d448 + 2 * Carousel.arrowRoom;

  final _carousel = CarouselController();

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Carousel(
            controller: _carousel,
            align: CarouselAlign.start,
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
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _carousel,
            builder: (context, current, _) => ExcludeSemantics(
              child: Text(
                'Slide ${current + 1} of ${switch (_carousel.snapCount) {
                  0 => _notes.length,
                  final count => count,
                }}',
                textAlign: TextAlign.center,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
