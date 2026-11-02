import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PolaroidPhotoWallExample extends StatelessWidget {
  const PolaroidPhotoWallExample({super.key});

  static const double _photoWidth = Spacing.d112 * 2;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d24),
    child: Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: Spacing.d40,
        children: [
          Transform.translate(
            offset: const Offset(Spacing.d16, 0),
            child: const Polaroid(
              width: _photoWidth,
              tape: PaperTape.top,
              tiltDegrees: -3,
              seed: 'w1',
              children: [
                PolaroidImage(
                  scene: PolaroidScene.house,
                  seed: 'w1i',
                  label: 'A yellow house',
                ),
                PolaroidCaption(Text('home')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: Spacing.d32),
            child: Polaroid(
              width: _photoWidth,
              fastener: FastenerKind.pin,
              tiltDegrees: 2.5,
              seed: 'w2',
              children: [
                PolaroidImage(
                  scene: PolaroidScene.sea,
                  date: "'25 8 09",
                  seed: 'w2i',
                  label: 'A sailboat at sunset',
                ),
                PolaroidCaption(Text('the ferry')),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(-Spacing.d16, 0),
            child: const Stack(
              clipBehavior: Clip.none,
              children: [
                Polaroid(
                  width: _photoWidth,
                  tape: PaperTape.corner,
                  tiltDegrees: -1.5,
                  seed: 'w3',
                  children: [
                    PolaroidImage(
                      scene: PolaroidScene.night,
                      seed: 'w3i',
                      label: 'Roofs under a moon',
                    ),
                    PolaroidCaption(Text('11pm')),
                  ],
                ),
                Positioned(
                  right: -Spacing.d20,
                  bottom: -Spacing.d16,
                  child: Sticker('done', size: Spacing.d64, rotate: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
