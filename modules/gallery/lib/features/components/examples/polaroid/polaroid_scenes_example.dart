import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PolaroidScenesExample extends StatelessWidget {
  const PolaroidScenesExample({super.key});

  static const double _maxPhotoWidth = Spacing.d112 * 2;
  static const double _fourColumnsFrom = Spacing.d256 * 3;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d24),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth >= _fourColumnsFrom) {
          true => 4,
          false => 2,
        };
        final cell =
            (constraints.maxWidth - Spacing.d24 * (columns - 1)) / columns;
        final width = math.min(cell, _maxPhotoWidth);
        return Wrap(
          spacing: Spacing.d24,
          runSpacing: Spacing.d48,
          children: [
            for (final photo in [
              Polaroid(
                width: width,
                tape: PaperTape.top,
                seed: 'p1',
                children: const [
                  PolaroidImage(scene: PolaroidScene.hills, seed: 's1'),
                  PolaroidCaption(Text('august, finally')),
                ],
              ),
              Polaroid(
                width: width,
                fastener: FastenerKind.pin,
                seed: 'p2',
                children: const [
                  PolaroidImage(
                    scene: PolaroidScene.sea,
                    date: "'25 8 09",
                    seed: 's2',
                  ),
                  PolaroidCaption(Text('the ferry home')),
                ],
              ),
              Polaroid(
                width: width,
                fastener: FastenerKind.clip,
                seed: 'p3',
                children: const [
                  PolaroidImage(scene: PolaroidScene.house, seed: 's3'),
                  PolaroidCaption(Text("gran's house")),
                ],
              ),
              Polaroid(
                width: width,
                tape: PaperTape.both,
                tapeKind: TapeKind.washiDots,
                seed: 'p4',
                children: const [
                  PolaroidImage(
                    scene: PolaroidScene.night,
                    date: "'25 9 24",
                    seed: 's4',
                  ),
                  PolaroidCaption(Text('last night, 11pm')),
                ],
              ),
            ])
              SizedBox(
                width: cell,
                child: Center(child: photo),
              ),
          ],
        );
      },
    ),
  );
}
