import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stubby saying "oops" under a burst, and a pink sticky note under a
/// lightning bolt: "sorry! that one is on us".
///
/// Mirrors upstream `src/blocks/error-500/components/error-500-scene.tsx`.
class Error500Scene extends StatelessWidget {
  const Error500Scene({super.key});

  static const double _burstStart = -36;
  static const double _burstTop = -12;
  static const double _boltTop = -56;
  static const double _boltEnd = -16;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.d24),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: Spacing.d32,
          runSpacing: Spacing.d32,
          children: [
            const Stack(
              clipBehavior: Clip.none,
              children: [
                Mascot(pose: 'oops', size: 196),
                PositionedDirectional(
                  start: _burstStart,
                  top: _burstTop,
                  child: Doodle('exclaim-burst', size: 52, seed: 'e500-burst'),
                ),
              ],
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                StickyNote(
                  color: StickyColor.pink,
                  tape: PaperTape.top,
                  seed: 'e500-note',
                  children: [
                    const StickyNoteTitle(Text('sorry!')),
                    StickyNoteContent(
                      Text(
                        'that one is on us',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 20,
                          cssLineHeight: 28 / 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const PositionedDirectional(
                  end: _boltEnd,
                  top: _boltTop,
                  child: Doodle('lightning', size: 72, seed: 'e500-bolt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
