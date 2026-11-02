import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A hand-drawn brand mark for a sign-in button, in the ink of the text
/// around it.
///
/// Mirrors upstream `src/blocks/login-01/components/login-01-brand-marks.tsx`.
class Login01BrandMark extends StatelessWidget {
  const Login01BrandMark(this.name, {super.key, this.size = Spacing.d16});

  /// The mark: `google`.
  final String name;

  /// The size in pixels.
  final double size;

  static const Map<String, ArtDef> _marks = {
    'google': ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart(
          'M20.3 8.6 C18.8 5.2 15.4 3.5 12 3.9 C7.6 4.4 4.2 8.2 4.3 12.6 C4.4 17.2 7.9 20.6 12 20.5 C16.3 20.4 19.8 17.4 20 12.4',
          1.15,
        ),
        StrokePart('M12.2 12.5 L20.1 12.4', 1.1),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final def = _marks[name];
    if (def == null) return SizedBox.square(dimension: size);
    return InkArt(
      cacheKey: 'auth-brand|$name|${JsMath.numberToString(size)}',
      draw: () => drawSkeleton(
        def,
        size,
        name,
        const DrawOpts(tone: ArtTone.ui, kind: ArtKind.icon, nib: 1.6),
      ).result,
      size: Size.square(size),
    );
  }
}
