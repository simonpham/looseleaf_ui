import 'dart:ui';

import 'package:looseleaf_ui/src/theme/theme.dart';

/// What a recipe draws for: the bucketed box, seed and drawing context, like
/// upstream `FrameRequest` (`src/lib/ink/react/cache.ts`).
class InkFrameRequest {
  const InkFrameRequest({
    required this.box,
    required this.seed,
    this.tier = LooseleafTier.lo,
    this.density = LooseleafDensity.comfortable,
    this.textDirection = TextDirection.ltr,
    this.knobs = const LooseleafKnobs(),
    this.pad,
    this.lazy = const {},
    this.lazyOnly = false,
  });

  /// The box, already bucketed with [bucketBox].
  final Size box;
  final String seed;
  final LooseleafTier tier;
  final LooseleafDensity density;
  final TextDirection textDirection;
  final LooseleafKnobs knobs;

  /// A fixed pad overriding the recipe's.
  final double? pad;

  /// Lazy layers (drawn only once needed, like `focus`) to include.
  final Set<String> lazy;

  /// Whether to draw only the [lazy] layers.
  final bool lazyOnly;

  /// The tier ink is drawn at: calm density always draws `lo`.
  LooseleafTier get effectiveTier => switch (density) {
    LooseleafDensity.calm => LooseleafTier.lo,
    _ => tier,
  };

  InkFrameRequest withLazy(Set<String> lazy, {required bool lazyOnly}) =>
      InkFrameRequest(
        box: box,
        seed: seed,
        tier: tier,
        density: density,
        textDirection: textDirection,
        knobs: knobs,
        pad: pad,
        lazy: lazy,
        lazyOnly: lazyOnly,
      );

  /// Rounds a size to the 4×2 px grid frames are cached on, like upstream
  /// `bucketBox`, so tiny resizes reuse the same drawing.
  static Size bucketBox(Size size) => Size(
    _bucket(size.width, 4),
    _bucket(size.height, 2),
  );

  static double _bucket(double value, double step) {
    final rounded = (value / step + 0.5).floor() * step;
    if (rounded < step) return step;
    return rounded;
  }
}
