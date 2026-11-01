import 'package:looseleaf_ui/src/painter/markup/ink_affine.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';
import 'package:looseleaf_ui/src/painter/markup/number_scanner.dart';

/// Parses an SVG `transform` list: `matrix`, `translate`, `scale`, `rotate`
/// (with an optional center), `skewX` and `skewY`, composed left to right.
abstract final class TransformParser {
  static final RegExp _item = RegExp(r'([a-zA-Z]+)\s*\(([^)]*)\)');

  static InkAffine parse(String source) {
    var result = InkAffine.identity;
    var consumed = 0;
    for (final match in _item.allMatches(source)) {
      _checkGap(source, consumed, match.start);
      consumed = match.end;
      final args = _numbers(match[2] ?? '');
      result = result.multiply(_one(match[1] ?? '', args, source));
    }
    _checkGap(source, consumed, source.length);
    return result;
  }

  static void _checkGap(String source, int from, int to) {
    final gap = source.substring(from, to).replaceAll(RegExp(r'[\s,]'), '');
    if (gap.isNotEmpty) throw InkMarkupError('bad transform "$source"');
  }

  static List<double> _numbers(String text) {
    final scan = NumberScanner(text);
    final out = <double>[];
    while (!scan.done) {
      out.add(scan.number());
    }
    return out;
  }

  static InkAffine _one(String name, List<double> args, String source) =>
      switch ((name, args)) {
        ('matrix', [final a, final b, final c, final d, final e, final f]) =>
          InkAffine(a, b, c, d, e, f),
        ('translate', [final x]) => InkAffine.translate(x, 0),
        ('translate', [final x, final y]) => InkAffine.translate(x, y),
        ('scale', [final s]) => InkAffine.scale(s, s),
        ('scale', [final x, final y]) => InkAffine.scale(x, y),
        ('rotate', [final degrees]) => InkAffine.rotate(degrees),
        ('rotate', [final degrees, final cx, final cy]) => InkAffine.rotate(
          degrees,
          cx,
          cy,
        ),
        ('skewX', [final degrees]) => InkAffine.skewX(degrees),
        ('skewY', [final degrees]) => InkAffine.skewY(degrees),
        _ => throw InkMarkupError('bad transform "$source"'),
      };
}
