import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

String _quote(String s) {
  final out = StringBuffer('"');
  for (final c in s.codeUnits) {
    switch (c) {
      case 0x22:
        out.write(r'\"');
      case 0x5c:
        out.write(r'\\');
      case 0x08:
        out.write(r'\b');
      case 0x0c:
        out.write(r'\f');
      case 0x0a:
        out.write(r'\n');
      case 0x0d:
        out.write(r'\r');
      case 0x09:
        out.write(r'\t');
      case < 0x20:
        out.write('\\u${c.toRadixString(16).padLeft(4, '0')}');
      default:
        out.writeCharCode(c);
    }
  }
  out.write('"');
  return out.toString();
}

/// JSON with sorted object keys and JS number formatting, for memo keys.
/// Accepts JSON-like values (null, bool, num, String, List, Map with String
/// keys) and enums (by name). Leave a key out of a map where upstream has
/// `undefined`; a null value prints as `null`.
///
/// Mirrors `stableStringify` in `src/lib/ink/recipes/index.ts`.
String stableStringify(Object? v) {
  switch (v) {
    case null:
      return 'null';
    case bool():
      return '$v';
    case String():
      return _quote(v);
    case num():
      if (!v.isFinite) return '"NaN"';
      return JsMath.numberToString(v);
    case Enum():
      return _quote(v.name);
    case List():
      return '[${v.map(stableStringify).join(',')}]';
    case Map():
      final keys = [for (final key in v.keys) '$key']..sort();
      return '{${keys.map((k) => '${_quote(k)}:${stableStringify(v[k])}').join(',')}}';
    default:
      return '"[unhashable]"';
  }
}

/// [w] × [h] rounded to a grid of `q`, at least one cell.
///
/// Mirrors `bucketBox` in `src/lib/ink/recipes/index.ts`.
Box bucketBox(double w, double h, [(double, double) q = (4, 2)]) => Box(
  _atLeast(q.$1, JsMath.round(w / q.$1) * q.$1),
  _atLeast(q.$2, JsMath.round(h / q.$2) * q.$2),
);

double _atLeast(double min, double v) {
  if (v.isNaN) return v;
  if (v < min) return min;
  return v;
}

/// Stable memo key for knobs.
///
/// Mirrors `knobsKey` in `src/lib/ink/recipes/index.ts`.
String knobsKey(Knobs k) => k.key;
