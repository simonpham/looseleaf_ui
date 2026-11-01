import 'dart:ui';

import 'package:looseleaf_ui/src/theme/looseleaf_colors.dart';
import 'package:looseleaf_ui/src/theme/looseleaf_density.dart';
import 'package:looseleaf_ui/src/theme/looseleaf_knobs.dart';
import 'package:looseleaf_ui/src/theme/looseleaf_typography.dart';

/// Everything ink and widgets read from a [LooseleafTheme]: paint tokens,
/// blend mode, Kevin Sans styles, density, tier, knobs, motion, direction.
///
/// Mirrors `src/styles/looseleaf.css` and the ink provider
/// (`src/lib/ink/react/provider.tsx`). Upstream ships a light theme only.
class LooseleafThemeData {
  const LooseleafThemeData({
    this.colors = const LooseleafColors(),
    this.typography = const LooseleafTypography(),
    this.blendMode = BlendMode.multiply,
    this.shadowK = 1,
    this.density = LooseleafDensity.comfortable,
    this.tier = LooseleafTier.lo,
    this.knobs = const LooseleafKnobs(),
    this.motion = LooseleafMotion.system,
    this.textDirection = TextDirection.ltr,
  });

  /// The `--ll-*` paint tokens.
  final LooseleafColors colors;

  /// The Kevin Sans text styles.
  final LooseleafTypography typography;

  /// `--ll-blend`: how marker and highlighter layers mix with the ink under them.
  final BlendMode blendMode;

  /// `--ll-shadow-k`: scales every paper shadow.
  final double shadowK;

  final LooseleafDensity density;
  final LooseleafTier tier;

  /// The theme's knobs before [density] adjusts them; see [resolvedKnobs].
  final LooseleafKnobs knobs;

  final LooseleafMotion motion;
  final TextDirection textDirection;

  /// The tier ink is drawn at: calm density always draws `lo`.
  LooseleafTier get effectiveTier => switch (density) {
    LooseleafDensity.calm => LooseleafTier.lo,
    _ => tier,
  };

  /// The knobs recipes draw with at this density.
  LooseleafKnobs get resolvedKnobs => knobs.resolve(density);

  /// Whether the whole frame stays put on hover (no tilt), like `data-still`.
  bool get still =>
      density == LooseleafDensity.calm || motion == LooseleafMotion.reduced;

  /// The value of a numeric `--ll-*` variable used in ink markup.
  double? scalar(String name) => switch (name) {
    'shadow-k' => shadowK,
    _ => null,
  };

  LooseleafThemeData copyWith({
    LooseleafColors? colors,
    LooseleafTypography? typography,
    BlendMode? blendMode,
    double? shadowK,
    LooseleafDensity? density,
    LooseleafTier? tier,
    LooseleafKnobs? knobs,
    LooseleafMotion? motion,
    TextDirection? textDirection,
  }) => LooseleafThemeData(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    blendMode: blendMode ?? this.blendMode,
    shadowK: shadowK ?? this.shadowK,
    density: density ?? this.density,
    tier: tier ?? this.tier,
    knobs: knobs ?? this.knobs,
    motion: motion ?? this.motion,
    textDirection: textDirection ?? this.textDirection,
  );

  @override
  bool operator ==(Object other) =>
      other is LooseleafThemeData &&
      other.colors == colors &&
      other.typography == typography &&
      other.blendMode == blendMode &&
      other.shadowK == shadowK &&
      other.density == density &&
      other.tier == tier &&
      other.knobs == knobs &&
      other.motion == motion &&
      other.textDirection == textDirection;

  @override
  int get hashCode => Object.hash(
    colors,
    typography,
    blendMode,
    shadowK,
    density,
    tier,
    knobs,
    motion,
    textDirection,
  );
}
