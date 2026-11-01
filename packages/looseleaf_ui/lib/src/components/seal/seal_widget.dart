import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A seal or award badge drawn like a sticker without the white edge: a
/// scalloped seal, a starburst, a rosette or medal with a hanging
/// [ribbon], a shield, plate, ticket or tag, a ringed seal lettered round
/// its rim ([ring], from 72 px), or a blob of sealing wax.
///
/// [text] is set in capitals in the middle (about 6 letters at 64 px, 10
/// at 96), with an optional smaller [sub] line from 96 px up; [mark] draws
/// a check or star instead, which still reads at 16 px. The seal is
/// [size] px across (at least 16; below 80 the small redraw is used).
///
/// It is an image named by its words ("Verified" for a check, "Award" for
/// a star); give [semanticLabel] for the meaning, or [decorative] when the
/// text beside it says the same.
///
/// ```dart
/// const Seal(mark: SealMark.check, tone: PaintKey.sky, size: 20,
///     shadow: false, semanticLabel: 'Verified')
/// const Seal(variant: SealVariant.wax, text: 'L', tone: PaintKey.red)
/// ```
///
/// Mirrors upstream `src/components/ui/seal.tsx`.
class Seal extends StatelessWidget {
  const Seal({
    super.key,
    this.variant = SealVariant.scallop,
    this.text,
    this.sub,
    this.mark,
    this.tone,
    this.ribbon,
    this.ring,
    this.deco,
    this.size = defaultSize,
    this.tier,
    this.tilt = 0,
    this.autoTilt = false,
    this.shadow = true,
    this.semanticLabel,
    this.decorative = false,
    this.seed,
  });

  /// Upstream's default `size`.
  static const double defaultSize = 96;

  /// The shape.
  final SealVariant variant;

  /// The words in the middle.
  final String? text;

  /// A smaller second line, from 96 px up; tickets ignore it.
  final String? sub;

  /// A drawn check or star instead of the words.
  final SealMark? mark;

  /// The colour: bubblegum by default, red for wax.
  final PaintKey? tone;

  /// The hanging ribbon's colour on a rosette or medal: tomato by default.
  final PaintKey? ribbon;

  /// Lettering round the rim of a ring seal, from 72 px up.
  final String? ring;

  /// The generator's small decoration, from 96 px up.
  final BadgeDeco? deco;

  /// Pixels across.
  final double size;

  /// The drawing quality; the theme's when null.
  final Tier? tier;

  /// A turn in degrees, used as given.
  final double tilt;

  /// Turns the seal by a seeded angle instead of [tilt], within 1.6 times
  /// the tilt budget (none at calm density).
  final bool autoTilt;

  /// The soft sticker drop shadow.
  final bool shadow;

  /// The accessible name; the words, "Verified" or "Award" when null.
  final String? semanticLabel;

  /// Hides the seal from screen readers.
  final bool decorative;

  /// Pins the hand; the variant and the words when null.
  final String? seed;

  /// The name a screen reader hears when there is no [semanticLabel].
  ///
  /// Mirrors `describe` in upstream `src/components/ui/seal.tsx`.
  String get description {
    if (text case final words? when words.isNotEmpty) {
      if (sub case final second? when second.isNotEmpty) {
        return '$words, $second';
      }
      return words;
    }
    return switch (mark) {
      SealMark.check => 'Verified',
      SealMark.star => 'Award',
      null => '${variant.name} seal',
    };
  }

  /// The seeded tilt in degrees, before the theme's clamp.
  ///
  /// Mirrors `autoTilt` in upstream `src/components/ui/seal.tsx`.
  static double seededTilt(String seed) => ((hashSeed(seed) % 640) - 320) / 100;

  double _degrees(LooseleafThemeData theme, String seed) {
    if (!autoTilt) return tilt;
    final max = PaperInk.tiltMax(theme) * 1.6;
    return seededTilt(seed).clamp(-max, max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final drawTier = tier ?? PaperInk.tier(theme);
    final s = seed ?? '${variant.name}:${text ?? mark?.name ?? ''}';
    final params = SealParams(
      variant: variant,
      text: text,
      sub: sub,
      mark: mark,
      tone: tone,
      ribbon: ribbon,
      ring: ring,
      deco: deco,
    );
    final px = math.max(16, JsMath.roundInt(size)).toDouble();
    final degrees = _degrees(theme, s);
    return InkArt(
      cacheKey: [
        'seal',
        JsMath.numberToString(px),
        drawTier.name,
        s,
        variant.name,
        text,
        sub,
        mark?.name,
        tone?.id,
        ribbon?.id,
        ring,
        deco?.name,
      ].join('|'),
      draw: () => sealArt(params, px, s, drawTier),
      shadow: shadow,
      rotation: degrees * math.pi / 180,
      semanticLabel: switch (decorative) {
        true => null,
        false => semanticLabel ?? description,
      },
    );
  }
}
