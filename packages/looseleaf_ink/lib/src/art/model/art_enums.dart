import 'package:looseleaf_ink/src/core/core.dart';

/// What a piece of art is; it picks the nib, the size variants and the
/// material of its fills.
///
/// Mirrors `ArtKind` in `src/lib/ink/art/types.ts`.
enum ArtKind { icon, doodle, sticker, mascot, prop, scene }

/// The accent an `acc` part is painted with: a stationery accent, the
/// highlighter or kraft.
///
/// Mirrors `ArtAccent` in `src/lib/ink/art/types.ts`.
enum ArtAccent {
  tomato(PaintKey.tomato),
  tangerine(PaintKey.tangerine),
  lemon(PaintKey.lemon),
  grass(PaintKey.grass),
  teal(PaintKey.teal),
  sky(PaintKey.sky),
  grape(PaintKey.grape),
  bubblegum(PaintKey.bubblegum),
  hi(PaintKey.hi),
  kraft(PaintKey.kraft);

  const ArtAccent(this.paint);

  /// The paint the accent resolves to.
  final PaintKey paint;
}

/// The lettering a text part is drawn in.
///
/// Mirrors `LetterFont` in `src/lib/ink/art/types.ts`.
enum LetterFont { hand, type }

/// The size variant of a definition: `micro`, `small`, the `master` parts,
/// or `hi` (the master plus its extra detail).
///
/// Mirrors `Variant` in `src/lib/ink/art-draw.ts`.
enum Variant { micro, small, master, hi }

/// How a scene layer's paper is ruled.
///
/// Mirrors `SceneLayer.rules` in `src/lib/ink/art/scenes/empty-scenes.ts`.
enum SceneRules {
  ruled('ruled'),
  lines('lines'),
  indexCard('index'),
  graph('graph'),
  dots('dots'),
  none('none');

  const SceneRules(this.id);

  /// The upstream name.
  final String id;
}
