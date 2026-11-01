import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A die-cut vinyl sticker from the engine's catalog: the art on a white
/// border with a cut line, a soft shadow and a small seeded tilt. Badges
/// (`done`, `sale`) are generated, stamps (`stamp-approved`) are pressed at
/// their own size, the rest are drawn.
///
/// [peel] folds the lower-right corner over: [Peel.auto] sizes the fold
/// from the sticker, `Peel(22)` folds 22 px. [rotate] turns it by degrees;
/// when null the tilt comes from the seed and stays within the theme's
/// tilt budget (none at calm density). An unknown [name] shows nothing.
///
/// ```dart
/// const Sticker('done', peel: Peel.auto())
/// const Sticker('cursor-click', size: 64, rotate: -5)
/// ```
///
/// Mirrors upstream `src/components/ui/sticker.tsx`.
class Sticker extends StatelessWidget {
  const Sticker(
    this.name, {
    super.key,
    this.size = defaultSize,
    this.peel,
    this.rotate,
    this.border,
    this.shadow = true,
    this.seed,
    this.semanticLabel,
  });

  /// Upstream's default `size`.
  static const double defaultSize = 96;

  /// `--ll-tilt-max`: how far the seeded tilt may turn a sticker.
  static const double tiltMaxDegrees = 2;

  /// The sticker's name in [stickers].
  final String name;

  /// The size in pixels, at least 32.
  final double size;

  /// A peeled corner; none when null.
  final Peel? peel;

  /// A turn in degrees; null tilts by the seed.
  final double? rotate;

  /// The white border width over the computed one.
  final double? border;

  /// The soft sticker drop shadow.
  final bool shadow;

  /// Pins the hand and the tilt; the name when null.
  final String? seed;

  /// Names the sticker for screen readers; decorative when null.
  final String? semanticLabel;

  /// The seeded tilt in degrees, before the theme's clamp.
  ///
  /// Mirrors `autoTilt` in upstream `src/components/ui/sticker.tsx`.
  static double autoTilt(String seed) => ((hashSeed(seed) % 640) - 320) / 100;

  double _tilt(LooseleafThemeData theme, String seed) {
    if (rotate case final degrees?) return degrees;
    final max = switch (theme.density) {
      LooseleafDensity.calm => 0.0,
      _ => tiltMaxDegrees,
    };
    return autoTilt(seed).clamp(-max, max);
  }

  @override
  Widget build(BuildContext context) {
    final def = stickers[name];
    if (def == null) return const SizedBox.shrink();
    final px = math.max(32, JsMath.roundInt(size)).toDouble();
    final s = seed ?? name;
    final peelKey = switch (peel) {
      null => 'false',
      Peel(size: null) => 'true',
      Peel(size: final fold?) => JsMath.numberToString(fold),
    };
    final borderKey = switch (border) {
      final width? => JsMath.numberToString(width),
      null => '',
    };
    final theme = LooseleafTheme.of(context);
    return InkArt(
      cacheKey:
          'sticker|$name|${JsMath.numberToString(px)}|$peelKey|'
          '$borderKey|$s',
      draw: () => renderSticker(
        def,
        px,
        s,
        DieCutOpts(peel: peel, border: border, idPrefix: 'll-sticker'),
      ),
      semanticLabel: semanticLabel,
      shadow: shadow,
      rotation: _tilt(theme, s) * math.pi / 180,
    );
  }
}
