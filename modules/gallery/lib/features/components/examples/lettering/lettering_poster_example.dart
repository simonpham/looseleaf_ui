import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LetteringPosterExample extends StatelessWidget {
  const LetteringPosterExample({super.key});

  static const _maxWidth = 576.0;
  static const _leadMaxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        tape: PaperTape.both,
        seed: 'poster',
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.d32,
          Spacing.d36,
          Spacing.d32,
          Spacing.d32,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                const Lettering(
                  'Paper Club',
                  size: LetteringSize.xl,
                  wobble: 0.6,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _leadMaxWidth),
                  child: Text(
                    'Third Thursday of the month. Bring something you wrote on the back of something else.',
                    style: theme.typography.interface(
                      cssSize: 18,
                      color: theme.colors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
            const PositionedDirectional(
              end: -Spacing.d8,
              bottom: -Spacing.d16,
              child: Sticker('wow', size: 80, rotate: 12),
            ),
          ],
        ),
      ),
    );
  }
}
