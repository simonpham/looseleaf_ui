import 'package:looseleaf_ink/src/core/core.dart';

/// JavaScript's `String(v)` for a data value (`null` gives `'null'`).
String jsString(Object? v) => switch (v) {
  null => 'null',
  final num n => JsMath.numberToString(n),
  _ => v.toString(),
};

final RegExp _radix = RegExp(r'^0([xob])([0-9a-f]+)$', caseSensitive: false);

/// JavaScript's `Number(s)` for a string: trimmed, empty is 0, `0x`/`0o`/
/// `0b` prefixes, otherwise a decimal literal or NaN.
double jsParse(String s) {
  final t = s.trim();
  if (t.isEmpty) return 0;
  if (_radix.firstMatch(t) case final m?) {
    final radix = switch ((m[1] ?? '').toLowerCase()) {
      'x' => 16,
      'o' => 8,
      _ => 2,
    };
    return int.tryParse(m[2] ?? '', radix: radix)?.toDouble() ?? double.nan;
  }
  if (t == 'Infinity' || t == '+Infinity') return double.infinity;
  if (t == '-Infinity') return double.negativeInfinity;
  if (!RegExp(
    r'^[+-]?(\d+\.?\d*|\.\d+)(e[+-]?\d+)?$',
    caseSensitive: false,
  ).hasMatch(t)) {
    return double.nan;
  }
  return double.tryParse(t) ?? double.nan;
}

/// JavaScript's `Number(v)` for a data value; null stands for `undefined`
/// (NaN).
double jsNumber(Object? v) => switch (v) {
  null => double.nan,
  final num n => n.toDouble(),
  final bool b => switch (b) {
    true => 1,
    false => 0,
  },
  final String s => jsParse(s),
  _ => double.nan,
};
