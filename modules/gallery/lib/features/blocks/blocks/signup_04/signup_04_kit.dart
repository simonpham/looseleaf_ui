import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A kraft sheet with a welcome kit of nine stickers to peel.
///
/// Mirrors upstream `src/blocks/signup-04/components/signup-04-kit.tsx`.
class Signup04Kit extends StatelessWidget {
  const Signup04Kit({super.key});

  static const _kit = [
    'rocket',
    'cactus',
    'sun-shades',
    'coffee-to-go',
    'cat-loaf',
    'party-popper',
    'rainbow',
    'thumbs-up',
    'donut',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const PaperBackground(
          stock: StockName.kraft,
          tilt: false,
          shadow: PaperShadow.none,
          seed: 'signup-04-kraft',
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.d16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d20,
              children: [
                Column(
                  spacing: Spacing.d4,
                  children: [
                    Text(
                      'your welcome kit',
                      textAlign: TextAlign.center,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 36,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    Text(
                      'Peel one off. It is yours to keep.',
                      textAlign: TextAlign.center,
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: 14,
                        color: theme.colors.inkSoft,
                      ),
                    ),
                  ],
                ),
                const StickerSheet(
                  title: 'Welcome kit',
                  stickers: _kit,
                  columns: 3,
                  size: 60,
                  seed: 'signup-04-sheet',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
