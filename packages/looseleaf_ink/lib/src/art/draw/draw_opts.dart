import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// How art is inked: `ui` (icons: the current text colour, no accents) or
/// `doodle` (ink and accents).
enum ArtTone { ui, doodle }

/// Options for drawing art.
///
/// Mirrors `DrawOpts` in `src/lib/ink/art-draw.ts`.
class DrawOpts {
  /// Drawing options; null fields use the kind's defaults.
  const DrawOpts({
    this.tone,
    this.tier,
    this.ink,
    this.accent,
    this.kind,
    this.variant,
    this.nib,
    this.shade,
    this.grain,
    this.crisp,
    this.calm,
    this.knobs,
    this.silAll,
    this.pad,
  });

  /// The tone; `ui` for icons, `doodle` otherwise.
  final ArtTone? tone;

  /// The output tier.
  final Tier? tier;

  /// The outline ink; `current` in the `ui` tone, ink otherwise.
  final PaintKey? ink;

  /// The accent over the definition's.
  final ArtAccent? accent;

  /// The kind over the definition's.
  final ArtKind? kind;

  /// The variant over the size's.
  final Variant? variant;

  /// The nib width in pixels.
  final double? nib;

  /// Shade (unused by the drawing).
  final bool? shade;

  /// Paper grain.
  final bool? grain;

  /// Simple strokes.
  final bool? crisp;

  /// Calm ink: less wobble.
  final bool? calm;

  /// Ink knobs.
  final Knobs? knobs;

  /// Every stroke joins the silhouette, not only the ink outlines.
  final bool? silAll;

  /// Padding over the computed one.
  final double? pad;
}

/// The size of a peeled sticker corner: automatic or in pixels.
///
/// Mirrors `DieCutOpts.peel` in `src/lib/ink/art-draw.ts`.
final class Peel {
  /// A fold of [size] pixels; 0 draws no peel.
  const Peel(double this.size);

  /// A fold sized from the sticker.
  const Peel.auto() : size = null;

  /// The fold in pixels, or null for automatic.
  final double? size;
}

/// Options for die-cut stickers and mascots.
///
/// Mirrors `DieCutOpts` in `src/lib/ink/art-draw.ts`.
class DieCutOpts extends DrawOpts {
  /// Die-cut options.
  const DieCutOpts({
    super.tone,
    super.tier,
    super.ink,
    super.accent,
    super.kind,
    super.variant,
    super.nib,
    super.shade,
    super.grain,
    super.crisp,
    super.calm,
    super.knobs,
    super.silAll,
    super.pad,
    this.border,
    this.peel,
    this.shadow,
    this.idPrefix,
  });

  /// The white border width.
  final double? border;

  /// A peeled corner.
  final Peel? peel;

  /// A soft drop shadow.
  final bool? shadow;

  /// The id prefix of the silhouette defs.
  final String? idPrefix;
}
