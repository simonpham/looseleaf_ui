import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [Rating]'s glyph size, from `glyph` in upstream
/// `src/components/ui/rating.tsx` (`size-5`, `size-6`, `size-8`).
enum RatingSize {
  sm(Spacing.d20),
  regular(Spacing.d24),
  lg(Spacing.d32);

  const RatingSize(this.glyph);

  /// The glyph's side.
  final double glyph;
}
