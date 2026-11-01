import 'package:looseleaf_ink/src/art/dsl/check_path.dart';
import 'package:looseleaf_ink/src/art/dsl/kind_of.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// How serious a [Problem] is.
enum ProblemLevel { error, warn }

/// One thing [validateArt] found, [at] naming the tier and part index.
///
/// Mirrors `Problem` in `src/lib/ink/art/dsl.ts`.
final class Problem {
  /// A problem.
  const Problem(this.level, this.code, this.msg, [this.at]);

  /// Error or warning.
  final ProblemLevel level;

  /// A short code, e.g. `bounds` or `budget`.
  final String code;

  /// The message.
  final String msg;

  /// Where, e.g. `parts[2]`.
  final String? at;
}

/// Whether a lettering font has a glyph: true, false, or null for unknown.
///
/// Mirrors `GlyphLookup` in `src/lib/ink/art/dsl.ts`.
typedef GlyphLookup = bool? Function(String font, String ch);

/// The area art of a kind should stay inside, `(x0, y0, x1, y1)`.
///
/// Mirrors `USABLE` in `src/lib/ink/art/dsl.ts`.
(double, double, double, double)? usableArea(ArtKind kind) => switch (kind) {
  ArtKind.icon => (2, 2, 22, 22),
  ArtKind.doodle => (4, 4, 60, 60),
  ArtKind.sticker => (6, 6, 58, 58),
  ArtKind.mascot => (4, 3, 60, 70),
  _ => null,
};

/// The most fills and strokes a tier of a kind may have.
///
/// Mirrors `BUDGET` in `src/lib/ink/art/dsl.ts`.
int? partBudget(ArtKind kind, String tier) => switch ((kind, tier)) {
  (ArtKind.icon, 'parts') => 6,
  (ArtKind.icon, 'small') => 4,
  (ArtKind.icon, 'micro') => 3,
  (ArtKind.icon, 'hi') => 6,
  (ArtKind.doodle, 'parts') => 14,
  (ArtKind.doodle, 'small') => 9,
  (ArtKind.doodle, 'micro') => 5,
  (ArtKind.doodle, 'hi') => 8,
  (ArtKind.sticker, 'parts') => 24,
  (ArtKind.sticker, 'small') => 16,
  (ArtKind.sticker, 'micro') => 8,
  (ArtKind.sticker, 'hi') => 10,
  (ArtKind.mascot, 'parts') => 34,
  (ArtKind.mascot, 'small') => 22,
  (ArtKind.mascot, 'micro') => 12,
  (ArtKind.mascot, 'hi') => 12,
  _ => null,
};

String _n(num v) => JsMath.numberToString(v);

double? _widthOf(ArtPart p) => switch (p) {
  StrokePart(:final width) => width,
  ColourStrokePart(:final width) => width,
  _ => null,
};

String? _pathOf(ArtPart p) => switch (p) {
  FillPart(:final d) => d,
  StrokePart(:final d) => d,
  ColourStrokePart(:final d) => d,
  HighlightPart(:final d) => d,
  _ => null,
};

/// Checks one tier of parts against the grammar, the colours, the usable
/// area of [kind] and the stroke widths.
///
/// Mirrors `validateParts` in `src/lib/ink/art/dsl.ts`.
List<Problem> validateParts(
  List<ArtPart> parts,
  ArtKind kind,
  String tier,
  bool hasAccent, [
  GlyphLookup? glyph,
]) {
  final out = <Problem>[];
  final area = usableArea(kind);
  for (var idx = 0; idx < parts.length; idx++) {
    final p = parts[idx];
    final at = '$tier[$idx]';
    void error(String code, String msg) =>
        out.add(Problem(ProblemLevel.error, code, msg, at));
    void warn(String code, String msg) =>
        out.add(Problem(ProblemLevel.warn, code, msg, at));
    switch (p) {
      case FillPart(:final colour, :final mis):
        if (colour.isAccent && !hasAccent && kind == ArtKind.icon) {
          warn(
            'accent',
            "'acc' part but the def has no `accent` (falls back to the "
                'highlighter)',
          );
        }
        if (mis != null && !(mis >= 0 && mis <= 3)) {
          error('mis', 'fill misregistration multiplier must be 0..3');
        }
      case ColourStrokePart(:final colour) when colour.isSilhouette:
        error('colour', '"${colour.id}" is not an allowed stroke color');
      case DotPart(:final x, :final y, :final r):
        if (!x.isFinite || !y.isFinite) {
          error('part-shape', 'dot needs numeric x y');
        }
        if (area case (final x0, final y0, final x1, final y1)
            when x.isFinite &&
                y.isFinite &&
                (x < x0 || x > x1 || y < y0 || y > y1)) {
          error(
            'bounds',
            'dot (${_n(x)}, ${_n(y)}) is outside the usable area '
                '${_n(x0)},${_n(y0)}..${_n(x1)},${_n(y1)}',
          );
        }
        final maxR = switch (tier) {
          'micro' => 8,
          _ => 6,
        };
        if (r != null && !(r >= 0.6 && r <= maxR)) {
          warn(
            'dot-radius',
            'dot radius ${_n(r)} is outside 0.6..$maxR grid units',
          );
        }
        continue;
      case TextPart(:final text, :final x, :final y, :final size, :final font):
        final name = (font ?? LetterFont.hand).name;
        if (glyph != null) {
          for (final rune in text.toUpperCase().runes) {
            final ch = String.fromCharCode(rune);
            if (ch != ' ' && glyph(name, ch) == false) {
              error('text', 'no glyph for "$ch" in the $name lettering');
            }
          }
        }
        if (!x.isFinite || !y.isFinite || !size.isFinite) {
          error('part-shape', 'text needs numeric x y size');
        }
        continue;
      case _:
        break;
    }
    if (_widthOf(p) case final wm?) {
      final lo = switch (kind == ArtKind.icon && tier != 'hi') {
        true => 0.6,
        false => 0.45,
      };
      final hi = switch ((tier, kind)) {
        ('micro', _) => 1.8,
        (_, ArtKind.icon) => 1.4,
        _ => 1.5,
      };
      if (!(wm >= 0.4 && wm <= 1.8)) {
        error('width', 'widthMul ${_n(wm)} is outside 0.4..1.8');
      }
      if (wm >= 0.4 && wm <= 1.8 && (wm < lo || wm > hi)) {
        warn(
          'width',
          'widthMul ${_n(wm)} is outside ${_n(lo)}..${_n(hi)} for '
              '${kind.name} $tier',
        );
      }
    }
    final d = _pathOf(p);
    if (d == null) continue;
    final r = checkPath(d);
    for (final m in r.errors) {
      error('path', m);
    }
    for (final m in r.warnings) {
      warn('path-style', m);
    }
    final silFill = p is FillPart && p.colour.isSilhouette;
    if (r.errors.isNotEmpty || silFill) continue;
    if ((r.bbox, area) case (
      final BBox box,
      (final ax0, final ay0, final ax1, final ay1),
    )) {
      const slack = 0.5;
      final outside =
          box.x0 < ax0 - slack ||
          box.y0 < ay0 - slack ||
          box.x1 > ax1 + slack ||
          box.y1 > ay1 + slack;
      if (outside) {
        String f(double v) => JsMath.toFixed(v, 1);
        error(
          'bounds',
          'path extent ${f(box.x0)},${f(box.y0)}..${f(box.x1)},${f(box.y1)} '
              'leaves the usable area ${_n(ax0)},${_n(ay0)}..${_n(ax1)},${_n(ay1)}',
        );
      }
    }
  }
  return out;
}

String _partKey(ArtPart p) {
  String o(num? v) => switch (v) {
    final num n => _n(n),
    null => '_',
  };
  String hand(Hand? h) => switch (h) {
    final Hand h => '${h.start?.name}/${h.end?.name}/${o(h.taper)}',
    null => '_',
  };
  return switch (p) {
    FillPart(:final colour, :final d, :final mis) =>
      'f|${colour.id}|$d|${o(mis)}',
    StrokePart(:final d, :final width, hand: final h) =>
      's|$d|${o(width)}|${hand(h)}',
    ColourStrokePart(:final colour, :final d, :final width, hand: final h) =>
      'c|${colour.id}|$d|${o(width)}|${hand(h)}',
    DotPart(:final x, :final y, :final r) => 'd|${o(x)}|${o(y)}|${o(r)}',
    HighlightPart(:final d, :final width) => 'h|$d|${o(width)}',
    TextPart(:final text, :final x, :final y, :final size) =>
      't|$text|${o(x)}|${o(y)}|${o(size)}|${p.colour?.id}|${p.font?.name}',
  };
}

/// Checks a whole definition: grid, parts per tier, accent, nib, tags and
/// the fill and stroke budget of its kind. Upstream runs it on every
/// definition in development; the shipped catalog passes it.
///
/// Mirrors `validateArt` in `src/lib/ink/art/dsl.ts`.
List<Problem> validateArt(ArtDef def, {ArtKind? kind, GlyphLookup? glyph}) {
  final out = <Problem>[];
  final k = kind ?? kindOfDef(def);
  final g = def.grid;
  bool inRange(double v) => v.isFinite && v >= 8 && v <= 512;
  final okGrid =
      (!g.pair && (g.w == 24 || g.w == 64)) ||
      (g.pair && inRange(g.w) && inRange(g.h));
  if (!okGrid) {
    final got = switch (g.pair) {
      true => '[${_n(g.w)},${_n(g.h)}]',
      false => _n(g.w),
    };
    out.add(
      Problem(
        ProblemLevel.error,
        'grid',
        'grid must be 24, 64 or [w, h] (got $got)',
      ),
    );
  }
  if (def.parts.isEmpty) {
    out.add(
      const Problem(
        ProblemLevel.error,
        'parts',
        'a definition needs at least one part',
      ),
    );
  }
  if (def.nibK case final nibK? when !(nibK >= 0.02 && nibK <= 0.14)) {
    out.add(
      const Problem(ProblemLevel.error, 'nibK', 'nibK must be 0.02..0.14'),
    );
  }
  if (def.tags case final tags? when tags.any((t) => t.isEmpty)) {
    out.add(
      const Problem(
        ProblemLevel.error,
        'tags',
        'tags must be non-empty strings',
      ),
    );
  }
  final tiers = <(String, List<ArtPart>?)>[
    ('parts', def.parts),
    ('small', def.small),
    ('micro', def.micro),
    ('hi', def.hi),
  ];
  for (final (name, list) in tiers) {
    if (list == null) continue;
    out.addAll(validateParts(list, k, name, def.accent != null, glyph));
    final blots = list.whereType<DotPart>().length;
    final drawn = list.length - blots;
    if (partBudget(k, name) case final budget? when drawn > budget) {
      out.add(
        Problem(
          ProblemLevel.error,
          'budget',
          '$name has $drawn fills / strokes; the ${k.name} budget is $budget '
              '(put several strokes in one path with M)',
          name,
        ),
      );
    }
    if (blots > 8) {
      out.add(
        Problem(
          ProblemLevel.error,
          'budget',
          '$name has $blots blots; at most 8',
          name,
        ),
      );
    }
  }
  if (def.small case final small?) {
    final same =
        small.length == def.parts.length &&
        [
          for (var i = 0; i < small.length; i++)
            _partKey(small[i]) == _partKey(def.parts[i]),
        ].every((v) => v);
    if (same) {
      out.add(
        const Problem(
          ProblemLevel.warn,
          'small-copy',
          '`small` is identical to the master: redraw it (bigger silhouette, '
              'fewer details, heavier strokes)',
        ),
      );
    }
  }
  return out;
}
