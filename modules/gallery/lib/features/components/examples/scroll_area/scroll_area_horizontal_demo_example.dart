import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaHorizontalDemoExample extends StatelessWidget {
  const ScrollAreaHorizontalDemoExample({super.key});

  static const _works = [
    (artist: 'Mira', scene: PolaroidScene.hills),
    (artist: 'Tom', scene: PolaroidScene.sea),
    (artist: 'Vlad', scene: PolaroidScene.night),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: Spacing.d384,
      child: ScrollArea(
        orientation: ScrollAreaOrientation.horizontal,
        bleed: true,
        type: ScrollAreaType.always,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.d16),
          child: Row(
            spacing: Spacing.d16,
            children: [
              for (final work in _works)
                Polaroid(
                  seed: work.artist,
                  width: Spacing.d176 + Spacing.d32,
                  children: [
                    PolaroidImage(
                      scene: work.scene,
                      label: 'Drawing by ${work.artist}',
                      seed: work.scene.name,
                    ),
                    PolaroidCaption(
                      Text(
                        'Drawn by ${work.artist}',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
