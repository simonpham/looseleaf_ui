import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The brand marks the sign-up buttons draw, as hand-drawn icon art.
enum Signup02Brand {
  github(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart(
          'M6.3 3.9 C8 4 9.3 5 10.1 5.8 C11.4 5.5 12.7 5.5 14 5.8 '
          'C14.8 5 16.1 4 17.8 3.9 C18.4 5.2 18.4 6.6 18 7.8 '
          'C19.3 9 19.8 10.8 19.6 12.6 C19.2 16.6 15.9 19.1 12 19 '
          'C8.1 18.9 4.8 16.6 4.5 12.6 C4.3 10.8 4.8 9 6.1 7.8 '
          'C5.7 6.6 5.7 5.2 6.3 3.9',
          1.1,
        ),
        StrokePart('M9.9 19 C9.3 20.3 8 20.9 6.7 20.5', 0.95),
        StrokePart('M14.3 19 C15 20.4 16.4 20.9 17.9 20.3', 0.95),
      ],
    ),
  );

  const Signup02Brand(this.def);

  /// The mark's drawing.
  final ArtDef def;
}

/// A brand's mark in the ambient ink, drawn like an icon.
///
/// Mirrors upstream `src/blocks/signup-02/components/signup-02-brand-marks.tsx`.
class Signup02BrandMark extends StatelessWidget {
  const Signup02BrandMark(this.brand, {super.key, this.size = Spacing.d16});

  final Signup02Brand brand;
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
