import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Stubby, the pencil-stub mascot, as a die-cut sticker: one bold body with
/// a face, in any [pose] of [mascot] (`idle`, `wave`, `think`, `write`,
/// `sketch`, `celebrate`, `oops`, `shrug`, `sleep`, `peek`, `point`,
/// `carry`, `halt`, `search`, `unplug`, …).
///
/// Each size is its own drawing: under 28 px a face on a silhouette, 96 px
/// the master, 160 px adds a shine. [frame] picks a flipbook frame of the
/// pose (`mascotFrames['wave-1']`) when it has one. An unknown pose shows
/// nothing.
///
/// ```dart
/// const Mascot(pose: 'wave', size: 64, semanticLabel: 'Stubby waves')
/// ```
///
/// Mirrors upstream `src/components/ui/mascot.tsx`.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.pose = 'idle',
    this.size = defaultSize,
    this.seed,
    this.semanticLabel,
    this.frame,
    this.tier = LooseleafTier.lo,
    this.shadow = true,
  });

  /// Upstream's default `size`.
  static const double defaultSize = 96;

  /// The pose's name in [mascot].
  final String pose;

  /// The sticker's size in pixels, border included; at least 16.
  final double size;

  /// Pins the hand; the pose when null.
  final String? seed;

  /// Names the drawing for screen readers; decorative when null.
  final String? semanticLabel;

  /// A flipbook frame of the pose, when [mascotFrames] has `pose-frame`.
  final int? frame;

  /// The ink tier: `hi` adds grain and texture.
  final LooseleafTier tier;

  /// The soft sticker drop shadow.
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final flipbook = switch (frame) {
      final index? => mascotFrames['$pose-$index'],
      null => null,
    };
    final def = flipbook ?? mascot[pose];
    if (def == null) return const SizedBox.shrink();
    final px = math.max(16, JsMath.roundInt(size)).toDouble();
    final frameKey = switch (flipbook) {
      null => '',
      _ => '$frame',
    };
    return InkArt(
      cacheKey:
          'mascot|$pose|$frameKey|${JsMath.numberToString(px)}|${tier.name}|'
          '${seed ?? ''}',
      draw: () => drawMascot(
        def,
        px,
        seed ?? pose,
        MascotDrawOpts(
          tier: switch (tier) {
            LooseleafTier.lo => Tier.lo,
            LooseleafTier.hi => Tier.hi,
          },
          idPrefix: 'll-mascot',
        ),
      ).result,
      semanticLabel: semanticLabel,
      shadow: shadow,
    );
  }
}
