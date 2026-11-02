import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _stocks = [
  StockName.paper,
  StockName.stickyYellow,
  StockName.kraft,
  StockName.stickyBlue,
  StockName.indexCard,
];

class CarouselDefaultExample extends StatelessWidget {
  const CarouselDefaultExample({super.key});

  static const _maxWidth = 320 + 2 * Carousel.arrowRoom;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Carousel(
        semanticLabel: 'Numbered cards',
        seed: 'default',
        children: [
          CarouselContent(
            children: [
              for (var i = 0; i < 5; i++)
                CarouselItem(
                  semanticLabel: '${i + 1} of 5',
                  child: Card(
                    seed: 'c$i',
                    padding: EdgeInsets.zero,
                    stock: _stocks[i],
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 60,
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
        ],
      ),
    );
  }
}
