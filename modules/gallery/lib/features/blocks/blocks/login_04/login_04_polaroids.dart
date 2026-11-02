import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A kraft panel with three polaroids taped and pinned to it, and stickers
/// between them.
///
/// Mirrors upstream `src/blocks/login-04/components/login-04-polaroids.tsx`.
class Login04Polaroids extends StatelessWidget {
  const Login04Polaroids({super.key});

  static const double _boardWidth = 320;
  static const double _boardHeight = 576;
  static const double _photoWidth = 160;

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PaperBackground(
            stock: StockName.kraft,
            tilt: false,
            shadow: PaperShadow.none,
            seed: 'login-04-kraft',
          ),
          Center(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: _boardWidth,
                height: _boardHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PositionedDirectional(
                      start: 0,
                      top: Spacing.d8,
                      child: Polaroid(
                        width: _photoWidth,
                        tiltDegrees: -4,
                        tape: PaperTape.top,
                        tapeKind: TapeKind.washiDots,
                        seed: 'login-04-a',
                        children: [
                          PolaroidImage(
                            scene: PolaroidScene.hills,
                            seed: 'login-04-hills',
                          ),
                          PolaroidCaption(Text('august')),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      end: Spacing.d12,
                      top: Spacing.d176,
                      child: Polaroid(
                        width: _photoWidth,
                        tiltDegrees: 5,
                        fastener: FastenerKind.pin,
                        fastenerTone: Accent.tomato,
                        seed: 'login-04-b',
                        children: [
                          PolaroidImage(
                            scene: PolaroidScene.house,
                            date: "'25 9 24",
                            seed: 'login-04-house',
                          ),
                          PolaroidCaption(Text("gran's")),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      start: Spacing.d12,
                      top: 344,
                      child: Polaroid(
                        width: _photoWidth,
                        tiltDegrees: -2,
                        tape: PaperTape.corner,
                        tapeKind: TapeKind.clear,
                        seed: 'login-04-c',
                        children: [
                          PolaroidImage(
                            scene: PolaroidScene.sea,
                            seed: 'login-04-sea',
                          ),
                          PolaroidCaption(Text('the ferry')),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      end: Spacing.d4,
                      top: 0,
                      child: Sticker('rainbow', size: 76, rotate: -8),
                    ),
                    PositionedDirectional(
                      start: Spacing.d8,
                      top: Spacing.d240,
                      child: Sticker('cactus', size: 68, rotate: -6),
                    ),
                    PositionedDirectional(
                      end: Spacing.d8,
                      top: 488,
                      child: Sticker('donut', size: 64, rotate: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
