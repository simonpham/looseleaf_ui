import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The brand marks the sign-up buttons draw, as hand-drawn icon art.
enum Signup01Brand {
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

  const Signup01Brand(this.def);

  /// The mark's drawing.
  final ArtDef def;
}

/// A brand's mark in the ambient ink, drawn like an icon.
///
/// Mirrors upstream `src/blocks/signup-01/components/signup-01-brand-marks.tsx`.
class Signup01BrandMark extends StatelessWidget {
  const Signup01BrandMark(this.brand, {super.key, this.size = Spacing.d16});

  final Signup01Brand brand;
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
