import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The brand marks the sign-up buttons draw, as hand-drawn icon art.
enum Signup05Brand {
  apple(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart(
          'M12 8.2 C10.6 7.1 7.5 7.4 6.5 10.3 C5.6 13 6.8 16.6 8.4 18.7 '
          'C9.4 20 10.7 19.5 12 19 C13.3 19.5 14.6 20.2 15.7 18.8 '
          'C17.3 16.8 18.1 15.3 18.3 14.5 C16.3 13.6 15.9 10.7 17.8 9.3 '
          'C16.4 7.3 13.6 7 12 8.2',
          1.05,
        ),
        StrokePart('M12.1 7.8 C12 6.1 13.1 4.7 14.9 4.3', 1),
      ],
    ),
  ),
  google(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart(
          'M20.3 8.6 C18.8 5.2 15.4 3.5 12 3.9 C7.6 4.4 4.2 8.2 4.3 12.6 '
          'C4.4 17.2 7.9 20.6 12 20.5 C16.3 20.4 19.8 17.4 20 12.4',
          1.15,
        ),
        StrokePart('M12.2 12.5 L20.1 12.4', 1.1),
      ],
    ),
  );

  const Signup05Brand(this.def);

  /// The mark's drawing.
  final ArtDef def;
}

/// A brand's mark in the ambient ink, drawn like an icon.
///
/// Mirrors upstream `src/blocks/signup-05/components/signup-05-brand-marks.tsx`.
class Signup05BrandMark extends StatelessWidget {
  const Signup05BrandMark(this.brand, {super.key, this.size = Spacing.d16});

  final Signup05Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) => InkArt(
    cacheKey: 'auth-brand|${brand.name}|${JsMath.numberToString(size)}',
    draw: () => drawSkeleton(
      brand.def,
      size,
      brand.name,
      const DrawOpts(tone: ArtTone.ui, kind: ArtKind.icon, nib: 1.6),
    ).result,
    size: Size.square(size),
  );
}
