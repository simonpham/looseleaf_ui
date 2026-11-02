import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One number of "By the numbers": the figure in big script, a tally of it
/// with what a stroke counts, and what it counts below.
///
/// Mirrors a `dl` entry of `Stats` in upstream `src/docs/content/home/stats.tsx`.
class StatEntry extends StatelessWidget {
  const StatEntry({
    super.key,
    required this.value,
    required this.label,
    required this.strokes,
    required this.per,
  });

  final String value;
  final String label;

  /// Tally strokes drawn beside [value].
  final int strokes;

  /// What one stroke stands for.
  final String per;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                value,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 60,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d2,
                children: [
                  if (strokes > 0)
                    Tally(
                      count: strokes,
                      size: TallySize.sm,
                      label: '$strokes strokes: $per',
                      seed: 'stat-$label',
                    ),
                  Text(
                    per,
                    style: theme.typography.stamp(
                      cssSize: 14,
                      color: theme.colors.pencilText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            label,
            style: theme.typography.interface(
              cssSize: 15,
              color: theme.colors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
