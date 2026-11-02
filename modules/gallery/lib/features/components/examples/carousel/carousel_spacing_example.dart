import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CarouselSpacingExample extends StatelessWidget {
  const CarouselSpacingExample({super.key});

  static const _maxWidth = 384 + 2 * Carousel.arrowRoom;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Carousel(
        align: CarouselAlign.start,
        semanticLabel: 'Numbered cards, tightly spaced',
        itemFraction: 1 / 3,
        seed: 'spacing',
        children: [
          CarouselContent(
            gap: Spacing.d4,
            children: [
              for (var i = 0; i < 5; i++)
                CarouselItem(
                  semanticLabel: '${i + 1} of 5',
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.d4),
                    child: Card(
                      seed: 'space$i',
                      padding: EdgeInsets.zero,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: 30,
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
