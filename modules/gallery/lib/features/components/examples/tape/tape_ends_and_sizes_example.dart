import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TapeEndsAndSizesExample extends StatelessWidget {
  const TapeEndsAndSizesExample({super.key});

  static const _wide = 640.0;
  static const _strips = [
    (
      label: 'saw',
      tape: Tape(
        ends: TapeEnds.saw,
        length: 160,
        height: 24,
        seed: 'saw',
      ),
    ),
    (
      label: 'torn',
      tape: Tape(
        ends: TapeEnds.torn,
        length: 160,
        height: 24,
        seed: 'torn',
      ),
    ),
    (
      label: 'scissor',
      tape: Tape(
        kind: TapeKind.washiDots,
        ends: TapeEnds.scissor,
        length: 160,
        height: 24,
        color: Accent.sky,
        seed: 'scissor',
      ),
    ),
    (
      label: 'straight',
      tape: Tape(
        kind: TapeKind.washiDots,
        ends: TapeEnds.straight,
        length: 160,
        height: 24,
        color: Accent.grape,
        seed: 'straight',
      ),
    ),
    (
      label: 'short, 64 x 18',
      tape: Tape(
        kind: TapeKind.washiStripes,
        length: 64,
        height: 18,
        color: Accent.grass,
        seed: 'short, 64 x 18',
      ),
    ),
    (
      label: 'wide, 220 x 34',
      tape: Tape(
        kind: TapeKind.kraft,
        length: 220,
        height: 34,
        seed: 'wide, 220 x 34',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth >= _wide) {
          true => 3,
          false => 2,
        };
        final width =
            (constraints.maxWidth - Spacing.d32 - Spacing.d32 * (columns - 1)) /
                columns -
            Spacing.d1;
        return Padding(
          padding: const EdgeInsets.all(Spacing.d16),
          child: Wrap(
            spacing: Spacing.d32,
            runSpacing: Spacing.d28,
            children: [
              for (final strip in _strips)
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d8,
                    children: [
                      strip.tape,
                      Text(
                        strip.label,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
