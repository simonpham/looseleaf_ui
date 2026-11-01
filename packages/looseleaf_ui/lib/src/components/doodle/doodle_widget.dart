import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';

/// A hand-drawn doodle from the engine's catalog (`star`, `sun`, `flower`,
/// `mushroom`, …): line-led, one marker fill that misses the outline, a
/// light pencil shade. Below 72 px it switches to its simpler drawing; from
/// 128 px it draws at the `hi` tier.
///
/// An unknown [name] shows nothing.
///
/// ```dart
/// const Doodle('sun')
/// const Doodle('flower', size: 48, accent: ArtAccent.bubblegum, rotate: -8)
/// ```
///
/// Mirrors upstream `src/components/ui/doodle.tsx`.
class Doodle extends StatelessWidget {
  const Doodle(
    this.name, {
    super.key,
    this.size = defaultSize,
    this.accent,
    this.seed,
    this.semanticLabel,
    this.rotate = 0,
    this.flip = false,
  });

  /// Upstream's default `size`.
  static const double defaultSize = 96;

  /// The doodle's name in [doodles].
  final String name;

  /// The size in pixels, at least 24.
  final double size;

  /// The fill color over the doodle's own.
  final ArtAccent? accent;

  /// Pins the hand; the name when null.
  final String? seed;

  /// Names the doodle for screen readers; decorative when null.
  final String? semanticLabel;

  /// A turn in degrees, paint only.
  final double rotate;

  /// Mirrors the doodle horizontally.
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final def = doodles[name];
    if (def == null) return const SizedBox.shrink();
    final px = math.max(24, JsMath.roundInt(size)).toDouble();
    return InkArt(
      cacheKey:
          'doodle|$name|${JsMath.numberToString(px)}|${accent?.name ?? ''}|'
          '${seed ?? ''}',
      draw: () => drawSkeleton(
        def,
        px,
        seed ?? name,
        DrawOpts(tone: ArtTone.doodle, accent: accent, kind: ArtKind.doodle),
      ).result,
      size: Size.square(px),
      semanticLabel: semanticLabel,
      flipX: flip,
      rotation: rotate * math.pi / 180,
    );
  }
}
