import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The hero's collage: a polaroid of the hills, a sticky to-do, a roadmap
/// on an index card and Stubby waving. Laid over each other on a 416 by
/// 480 board when [scattered] (with a rocket sticker), else wrapped in a
/// centred row.
///
/// Mirrors upstream
/// `src/blocks/landing-hero-01/components/landing-hero-01-collage.tsx`.
class LandingHero01Collage extends StatelessWidget {
  const LandingHero01Collage({super.key, this.scattered = false});

  /// Whether the pieces overlap on a fixed board.
  final bool scattered;

  static const double boardWidth = 416;
  static const double _boardHeight = 480;
  static const double _cardWidth = 240;
  static const double _noteWidth = 176;

  @override
  Widget build(BuildContext context) {
    const photo = Polaroid(
      width: _cardWidth,
      seed: 'hero-photo',
      tape: PaperTape.top,
      tapeKind: TapeKind.washiDots,
      children: [
        PolaroidImage(
          scene: PolaroidScene.hills,
          label: 'A drawn hillside with one tree and a sun',
          seed: 'hero-hills',
        ),
        PolaroidCaption(Text('monday, 9:41')),
      ],
    );
    const note = StickyNote(
      width: _noteWidth,
      fastener: FastenerKind.pin,
      seed: 'hero-todo',
      children: [
        StickyNoteTitle(Text('todo')),
        StickyNoteContent(Text('ship the new page (friday!)')),
      ],
    );
    const roadmap = IndexCard(
      seed: 'hero-roadmap',
      fastener: FastenerKind.clip,
      maxWidth: _cardWidth,
      minHeight: Spacing.d40,
      children: [
        IndexCardHeader(children: [IndexCardTitle(Text('Roadmap'))]),
        IndexCardContent(
          children: [
            Text('1. draw the thing'),
            Text('2. show a friend'),
            Text('3. ship it'),
          ],
        ),
        IndexCardFooter(children: [Text('no. 0042')]),
      ],
    );
    const stubby = Mascot(pose: 'wave', size: 184);
    if (!scattered) {
      return const Padding(
        padding: EdgeInsets.only(top: Spacing.d8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: Spacing.d32,
          runSpacing: Spacing.d32,
          children: [photo, note, roadmap, stubby],
        ),
      );
    }
    return const SizedBox(
      width: boardWidth,
      height: _boardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(start: 0, top: Spacing.d8, child: photo),
          PositionedDirectional(start: 216, top: Spacing.d80, child: note),
          PositionedDirectional(start: Spacing.d40, top: 288, child: roadmap),
          PositionedDirectional(end: 0, bottom: 0, child: stubby),
          PositionedDirectional(
            top: -Spacing.d8,
            end: Spacing.d8,
            child: Sticker('rocket', size: 76, rotate: 10),
          ),
        ],
      ),
    );
  }
}
