import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A retro camera's date stamp: small orange mono figures with a glow (no
/// glow when calm). Decorative.
///
/// Mirrors the `date` span of `PolaroidImage` in upstream
/// `src/components/ui/polaroid.tsx`.
class PolaroidDate extends StatelessWidget {
  const PolaroidDate(this.date, {super.key});

  /// The stamp, like `'25 8 09`.
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final shade = theme.colors.shade;
    return ExcludeSemantics(
      child: Text(
        date,
        style: theme.typography
            .mono(
              cssSize: 11,
              cssLineHeight: 1.4,
              color: theme.colors.tangerine,
            )
            .copyWith(
              letterSpacing: 11 * 0.05,
              shadows: switch (PaperInk.calm(theme)) {
                true => null,
                false => [
                  Shadow(color: shade.withValues(alpha: 0.7), blurRadius: 2),
                  Shadow(color: shade.withValues(alpha: 0.45), blurRadius: 6),
                ],
              },
            ),
      ),
    );
  }
}
