import 'package:looseleaf_ink/src/core/core.dart';

/// The colour of a fill, stroke or text part: a paint, a paint washed
/// thinner (`key~`), the definition's accent (`acc`) or the die-cut
/// silhouette only (`sil`).
///
/// Mirrors `ArtColour` in `src/lib/ink/art/types.ts`.
final class ArtColour {
  /// A solid paint.
  const ArtColour(PaintKey this.paint) : washed = false, _role = _Role.paint;

  /// A paint laid as a thin wash (`key~`).
  const ArtColour.wash(PaintKey this.paint)
    : washed = true,
      _role = _Role.paint;

  const ArtColour._role(this._role) : paint = null, washed = false;

  /// The definition's accent (`acc`); skipped in the `ui` tone.
  static const ArtColour acc = ArtColour._role(_Role.accent);

  /// Only part of the sticker silhouette (`sil`), never painted.
  static const ArtColour sil = ArtColour._role(_Role.silhouette);

  /// The paint, or null for [acc] and [sil].
  final PaintKey? paint;

  /// Whether the paint is a wash (`key~`).
  final bool washed;

  final _Role _role;

  /// Whether this is [acc].
  bool get isAccent => _role == _Role.accent;

  /// Whether this is [sil].
  bool get isSilhouette => _role == _Role.silhouette;

  /// The upstream spelling: `lemon`, `sky~`, `acc` or `sil`.
  String get id => switch ((_role, paint, washed)) {
    (_Role.accent, _, _) => 'acc',
    (_Role.silhouette, _, _) => 'sil',
    (_, final key?, true) => '${key.id}~',
    (_, final key?, false) => key.id,
    _ => '',
  };

  /// Parses the upstream spelling, or returns null.
  static ArtColour? parse(String id) {
    if (id == 'acc') return acc;
    if (id == 'sil') return sil;
    if (id.endsWith('~')) {
      if (PaintKey.byId(id.substring(0, id.length - 1)) case final key?) {
        return ArtColour.wash(key);
      }
      return null;
    }
    if (PaintKey.byId(id) case final key?) return ArtColour(key);
    return null;
  }

  /// The paint this colour is drawn with, [accent] standing in for [acc].
  /// Null for [sil].
  PaintKey? resolve(PaintKey accent) => switch (_role) {
    _Role.accent => accent,
    _Role.silhouette => null,
    _Role.paint => paint,
  };
}

enum _Role { paint, accent, silhouette }
