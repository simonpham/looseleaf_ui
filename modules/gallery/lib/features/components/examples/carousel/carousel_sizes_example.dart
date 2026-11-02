import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CarouselSizesExample extends StatelessWidget {
  const CarouselSizesExample({super.key});

  static const _maxWidth = 384 + 2 * Carousel.arrowRoom;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Carousel(
        semanticLabel: 'Numbered cards, several at a time',
        itemFraction: 1 / 3,
        seed: 'sizes',
        children: [
          CarouselContent(
            children: [
              for (var i = 0; i < 5; i++)
                CarouselItem(
                  semanticLabel: '${i + 1} of 5',
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.d4),
                    child: Card(
                      seed: 'size$i',
                      padding: EdgeInsets.zero,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: 36,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
