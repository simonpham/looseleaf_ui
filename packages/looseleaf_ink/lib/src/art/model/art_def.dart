import 'package:looseleaf_ink/src/art/model/art_colour.dart';
import 'package:looseleaf_ink/src/art/model/art_enums.dart';
import 'package:looseleaf_ink/src/art/model/art_grid.dart';
import 'package:looseleaf_ink/src/art/model/art_part.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// A sticker: drawn art ([ArtDef]), a generated badge ([BadgeGen]) or a
/// rubber stamp ([StampGen]).
///
/// Mirrors `StickerDef` in `src/lib/ink/art/types.ts`.
sealed class StickerDef {
  const StickerDef();

  /// Search tags.
  List<String>? get tags;
}

/// A piece of art: parts on a grid, with optional `small`, `micro` and `hi`
/// variants.
///
/// Mirrors `ArtDef` in `src/lib/ink/art/types.ts`.
base class ArtDef extends StickerDef {
  /// A definition.
  const ArtDef({
    required this.grid,
    required this.parts,
    this.small,
    this.micro,
    this.hi,
    this.accent,
    this.nibK,
    this.tags,
    this.shade,
    this.tilt,
    this.rtlFlip = false,
    this.mirror,
    this.kind,
  });

  /// The drawing grid.
  final ArtGrid grid;

  /// The master parts.
  final List<ArtPart> parts;

  /// Parts for small sizes.
  final List<ArtPart>? small;

  /// Parts for the smallest sizes.
  final List<ArtPart>? micro;

  /// Extra detail drawn over the master at large sizes.
  final List<ArtPart>? hi;

  /// The accent `acc` parts use.
  final ArtAccent? accent;

  /// The nib width per pixel of size.
  final double? nibK;

  @override
  final List<String>? tags;

  /// Whether the art casts a shade (unused by the drawing).
  final bool? shade;

  /// A tilt in degrees around the bottom centre.
  final double? tilt;

  /// Whether the art flips in right-to-left layouts (`rtl: 'flip'`).
  final bool rtlFlip;

  /// Whether the art is symmetric enough to mirror.
  final bool? mirror;

  /// The kind; derived from the grid when null (see `kindOfDef`).
  final ArtKind? kind;
}

/// The badge outlines `badgeSkeleton` draws.
///
/// Mirrors `BadgeGen.shape` in `src/lib/ink/art/types.ts`.
enum BadgeShape {
  scallop,
  starburst,
  rosette,
  banner,
  tag,
  ticket,
  plate,
  shield,
  medal,
}

/// A small decoration on a badge.
///
/// Mirrors `BadgeGen.deco` in `src/lib/ink/art/types.ts`.
enum BadgeDeco { tick, star, sparkle, swoosh, percent }

/// Options of `badgeSkeleton`.
///
/// Mirrors `BadgeOpts` in `src/lib/ink/art/badge-gen.ts`.
final class BadgeOpts {
  /// Badge options.
  const BadgeOpts({
    this.shape,
    this.color,
    this.sub,
    this.bumps,
    this.amp,
    this.deco,
    this.textColor,
    this.tilt,
    this.tags,
    this.fill,
  });

  /// The outline; [BadgeShape.scallop] when null.
  final BadgeShape? shape;

  /// The badge colour; bubblegum when null.
  final PaintKey? color;

  /// A second, smaller line.
  final String? sub;

  /// Scallop or burst count.
  final int? bumps;

  /// Scallop depth.
  final double? amp;

  /// A decoration.
  final BadgeDeco? deco;

  /// The lettering colour; ink when null.
  final PaintKey? textColor;

  /// A tilt in degrees (unused by the skeleton).
  final double? tilt;

  /// Search tags.
  final List<String>? tags;

  /// A fill colour over [color].
  final ArtColour? fill;
}

/// A generated badge sticker.
///
/// Mirrors `BadgeGen` in `src/lib/ink/art/types.ts`.
final class BadgeGen extends StickerDef {
  /// A badge reading [text].
  const BadgeGen(this.text, {this.opts = const BadgeOpts()});

  /// The text.
  final String text;

  /// The badge options.
  final BadgeOpts opts;

  @override
  List<String>? get tags => opts.tags;
}

/// The rubber stamp outlines.
///
/// Mirrors `StampGen.shape` in `src/lib/ink/art/types.ts`.
enum StampShape {
  rect('rect'),
  round('round'),
  burst('burst'),
  voided('void');

  const StampShape(this.id);

  /// The upstream name.
  final String id;
}

/// The stamp pad inks.
///
/// Mirrors `StampGen.ink` in `src/lib/ink/art/types.ts`.
enum StampPadInk {
  red(PaintKey.red),
  inkYou(PaintKey.inkYou),
  green(PaintKey.green),
  ink(PaintKey.ink);

  const StampPadInk(this.paint);

  /// The paint.
  final PaintKey paint;
}

/// Options of `stamp`.
///
/// Mirrors `StampOpts` in `src/lib/ink/art/rubber-stamp.ts`.
final class StampOpts {
  /// Stamp options.
  const StampOpts({
    this.sub,
    this.ring,
    this.ink,
    this.w,
    this.h,
    this.tilt,
    this.ghost,
    this.dashed,
    this.wear,
    this.stars,
    this.tags,
    this.seed,
    this.grain,
  });

  /// A second line.
  final String? sub;

  /// Text around the rim of a round stamp.
  final String? ring;

  /// The ink; red when null.
  final StampPadInk? ink;

  /// The width.
  final double? w;

  /// The height.
  final double? h;

  /// The tilt in degrees; random in `[-5, 5)` when null.
  final double? tilt;

  /// A faint second impression.
  final bool? ghost;

  /// A dashed inner frame.
  final bool? dashed;

  /// Wear (unused by the drawing).
  final double? wear;

  /// Stars beside the text of a round stamp.
  final int? stars;

  /// Search tags.
  final List<String>? tags;

  /// The seed (string or number); the text when null.
  final Object? seed;

  /// Paper grain.
  final bool? grain;

  /// A copy with another [seed].
  StampOpts withSeed(Object seed) => StampOpts(
    sub: sub,
    ring: ring,
    ink: ink,
    w: w,
    h: h,
    tilt: tilt,
    ghost: ghost,
    dashed: dashed,
    wear: wear,
    stars: stars,
    tags: tags,
    seed: seed,
    grain: grain,
  );
}

/// A rubber stamp sticker.
///
/// Mirrors `StampGen` in `src/lib/ink/art/types.ts`.
final class StampGen extends StickerDef {
  /// A stamp reading [text].
  const StampGen(this.text, this.shape, {this.opts = const StampOpts()});

  /// The text.
  final String text;

  /// The outline.
  final StampShape shape;

  /// The stamp options.
  final StampOpts opts;

  @override
  List<String>? get tags => opts.tags;
}
