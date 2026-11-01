import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/text/glyph_data.dart';
import 'package:looseleaf_ink/src/art/text/glyph_font.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

const double _fit = 0.8;

final RegExp _commandRun = RegExp('([MLQZ])([^MLQZ]*)');
final RegExp _numberSeparators = RegExp('[ ,]+');

final Map<String, List<(String, List<double>)>> _parsed = {};

/// The font for [font].
///
/// Mirrors `GLYPH_FONTS` in `src/lib/ink/art/glyphs.ts`.
GlyphFont glyphFont(LetterFont font) => switch (font) {
  LetterFont.hand => glyphsHand,
  LetterFont.type => glyphsType,
};

List<(String, List<double>)> _commands(LetterFont font, String ch) {
  final key = '${font.name}$ch';
  if (_parsed[key] case final cached?) return cached;
  final out = <(String, List<double>)>[];
  final d = glyphFont(font).d[ch] ?? '';
  for (final m in _commandRun.allMatches(d)) {
    final args = (m[2] ?? '').trim();
    final nums = switch (args.isEmpty) {
      true => <double>[],
      false => [
        for (final s in args.split(_numberSeparators))
          double.tryParse(s) ?? double.nan,
      ],
    };
    out.add((m[1] ?? '', nums));
  }
  _parsed[key] = out;
  return out;
}

double _advance(GlyphFont f, String ch) => f.adv[ch] ?? f.adv[' '] ?? 300;

/// Whether the lettering [font] (`hand` or `type`) has a glyph for [ch].
///
/// Mirrors `hasGlyph` in `src/lib/ink/art/glyph-text.ts`.
bool hasGlyph(String font, String ch) {
  final f = switch (font) {
    'hand' => glyphsHand,
    'type' => glyphsType,
    _ => null,
  };
  if (f == null) return false;
  return ch == ' ' || (f.d[ch]?.isNotEmpty ?? false);
}

/// The width of [text] in [font] at em [size], with [spacing] between
/// letters.
///
/// Mirrors `measureText` in `src/lib/ink/art/glyph-text.ts`.
double measureText(
  LetterFont font,
  String text,
  double size, [
  double spacing = 0,
]) {
  final f = glyphFont(font);
  var w = 0.0;
  final t = text.toUpperCase();
  for (var i = 0; i < t.length; i++) {
    final gap = switch (i < t.length - 1) {
      true => spacing,
      false => 0.0,
    };
    w += (_advance(f, t[i]) / 1000) * size * _fit + gap;
  }
  return w;
}

/// The cap height of [font] at em [size].
///
/// Mirrors `capHeight` in `src/lib/ink/art/glyph-text.ts`.
double capHeight(LetterFont font, double size) =>
    (glyphFont(font).cap / 1000) * size * _fit;

/// Where a line of lettering sits on its `x`.
enum TextAnchor { start, middle, end }

/// Options of [textPath].
///
/// Mirrors `TextOpts` in `src/lib/ink/art/glyph-text.ts`.
final class TextOpts {
  /// Lettering options.
  const TextOpts({
    this.font,
    this.anchor,
    this.spacing,
    this.jitter,
    this.rot,
    this.squeeze,
    this.q,
  });

  /// The lettering; hand when null.
  final LetterFont? font;

  /// The anchor; middle when null.
  final TextAnchor? anchor;

  /// Extra space between letters.
  final double? spacing;

  /// Bounce and lean per letter, 0 to 1.
  final double? jitter;

  /// Rotation in degrees around `(x, y)`.
  final double? rot;

  /// Horizontal squeeze.
  final double? squeeze;

  /// The path grid (10, 20 or 100); 10 when null.
  final int? q;
}

/// A line of lettering as one filled path.
///
/// Mirrors `TextPath` in `src/lib/ink/art/glyph-text.ts`.
final class TextPath {
  /// A path.
  const TextPath({required this.d, required this.width, required this.bbox});

  /// The path data.
  final String d;

  /// The advance width.
  final double width;

  /// The bounds of the glyph points.
  final BBox bbox;
}

/// [text] in upper case as filled glyph outlines at em [em], anchored on
/// `(x, y)` (the baseline), with a little hand-set bounce from [rng].
///
/// Mirrors `textPath` in `src/lib/ink/art/glyph-text.ts`.
TextPath textPath(
  String text,
  double x,
  double y,
  double em,
  Rng rng, [
  TextOpts o = const TextOpts(),
]) {
  final font = o.font ?? LetterFont.hand;
  final f = glyphFont(font);
  final t = text.toUpperCase();
  final sq = o.squeeze ?? 1;
  final size = em * _fit;
  final s = size / 1000;
  final spacing = o.spacing ?? 0;
  final jit = (o.jitter ?? 0) * 0.3;
  final total = measureText(font, t, em, spacing) * sq;
  final x0 = switch (o.anchor) {
    TextAnchor.start => x,
    TextAnchor.end => x - total,
    _ => x - total / 2,
  };
  final w = PathWriter(o.q ?? 10);
  final ampY = 0.045 * size * jit;
  final ph = rng() * 6.28, ph2 = rng() * 6.28;
  final rot0 = ((o.rot ?? 0) * JsMath.pi) / 180;
  final cr = JsMath.cos(rot0), sr = JsMath.sin(rot0);
  var pen = 0.0;
  final bb = BBox.empty();
  for (var i = 0; i < t.length; i++) {
    final ch = t[i];
    final adv = (_advance(f, ch) / 1000) * size * sq;
    final cmds = _commands(font, ch);
    if (cmds.isNotEmpty) {
      final dy =
          ampY *
              (0.6 * JsMath.sin(i * 0.9 + ph) +
                  0.4 * JsMath.sin(i * 2.3 + ph2)) +
          rng.gauss(0, ampY * 0.3);
      final lean = (rng.gauss(0, 1.5) * jit * JsMath.pi) / 180;
      final gx = pen + adv / 2;
      const gy = 0.0;
      final cl = JsMath.cos(lean), sl = JsMath.sin(lean);
      final penAt = pen;
      Pt tr(double px, double py) {
        var gX = px * s * sq + penAt, gY = py * s + dy;
        final rx = gX - gx, ry = gY - gy;
        gX = gx + rx * cl - ry * sl;
        gY = gy + rx * sl + ry * cl;
        final ax = x0 - x + gX;
        return (x + ax * cr - gY * sr, y + ax * sr + gY * cr);
      }

      for (final (k, args) in cmds) {
        switch (k) {
          case 'M':
            final p = tr(args[0], args[1]);
            w.m(p.x, p.y);
            bb.grow(p.x, p.y);
          case 'L':
            final p = tr(args[0], args[1]);
            w.l(p.x, p.y);
            bb.grow(p.x, p.y);
          case 'Q':
            final c = tr(args[0], args[1]);
            final e = tr(args[2], args[3]);
            w.quad(c.x, c.y, e.x, e.y);
            bb.grow(e.x, e.y);
          case 'Z':
            w.z();
        }
      }
    }
    pen += adv + spacing;
  }
  if (bb.x0 == double.infinity) {
    return TextPath(d: w.d, width: total, bbox: BBox(x, y, x, y));
  }
  return TextPath(d: w.d, width: total, bbox: bb);
}
