import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _photos = [
  (
    scene: PolaroidScene.hills,
    caption: 'Day one: the ridge road',
    date: '3 Mar',
  ),
  (scene: PolaroidScene.sea, caption: 'Lunch by the harbour', date: '4 Mar'),
  (scene: PolaroidScene.house, caption: 'The yellow house', date: '5 Mar'),
  (scene: PolaroidScene.night, caption: 'Lanterns after dark', date: '5 Mar'),
  (scene: PolaroidScene.hills, caption: 'Heading home', date: '7 Mar'),
  (scene: PolaroidScene.sea, caption: 'The last swim', date: '7 Mar'),
];

class CarouselPhotosExample extends StatelessWidget {
  const CarouselPhotosExample({super.key});

  static const _maxWidth = 320 + 2 * Carousel.arrowRoom;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Carousel(
        semanticLabel: 'Trip photos',
        loop: true,
        seed: 'trip',
        children: [
          CarouselContent(
            children: [
              for (final (index, photo) in _photos.indexed)
                CarouselItem(
                  semanticLabel: '${index + 1} of ${_photos.length}',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Polaroid(
                      seed: 'p$index',
                      tiltDegrees: switch (index.isOdd) {
                        true => 1.2,
                        false => -1.2,
                      },
                      children: [
                        PolaroidImage(
                          scene: photo.scene,
                          date: photo.date,
                          seed: 's$index',
                          label: photo.caption,
                        ),
                        PolaroidCaption(Text(photo.caption)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const CarouselPrevious(),
          const CarouselNext(),
          const CarouselDots(),
          Builder(
            builder: (context) {
              final at = Carousel.maybeOf(context)?.selectedIndex ?? 0;
              return Padding(
                padding: const EdgeInsets.only(top: Spacing.d12),
                child: ExcludeSemantics(
                  child: Text(
                    '${_photos[at].date} · ${at + 1} of ${_photos.length}',
                    textAlign: TextAlign.center,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 20,
                      cssLineHeight: 1,
                      color: theme.colors.inkSoft,
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
