import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';

/// Scans SVG numbers out of attribute text, including the compact forms the
/// engine writes (`.4-1.2`, `1.5.5`, `-.3e-2`), skipping spaces and commas.
class NumberScanner {
  NumberScanner(this.source);

  final String source;
  int at = 0;

  /// Skips whitespace and at most one comma.
  void skipSeparators() {
    var comma = false;
    while (at < source.length) {
      final unit = source.codeUnitAt(at);
      if (_isSpace(unit)) {
        at++;
        continue;
      }
      if (unit == 0x2C && !comma) {
        comma = true;
        at++;
        continue;
      }
      return;
    }
  }

  /// Whether a number starts at the cursor (after separators).
  bool get atNumber {
    skipSeparators();
    if (at >= source.length) return false;
    final unit = source.codeUnitAt(at);
    return _isDigit(unit) || unit == 0x2E || unit == 0x2D || unit == 0x2B;
  }

  bool get done {
    skipSeparators();
    return at >= source.length;
  }

  /// Reads the next number.
  double number() {
    skipSeparators();
    final start = at;
    if (at < source.length && _isSign(source.codeUnitAt(at))) at++;
    var digits = _digits();
    if (at < source.length && source.codeUnitAt(at) == 0x2E) {
      at++;
      digits += _digits();
    }
    if (digits == 0) {
      throw InkMarkupError('expected a number at $start in "$source"');
    }
    if (at < source.length && (source.codeUnitAt(at) | 0x20) == 0x65) {
      final mark = at;
      at++;
      if (at < source.length && _isSign(source.codeUnitAt(at))) at++;
      if (_digits() == 0) at = mark;
    }
    return double.parse(source.substring(start, at));
  }

  /// Reads an arc flag: a lone `0` or `1`, which may touch what follows.
  bool flag() {
    skipSeparators();
    if (at >= source.length) {
      throw InkMarkupError('expected a flag in "$source"');
    }
    final unit = source.codeUnitAt(at);
    if (unit != 0x30 && unit != 0x31) {
      throw InkMarkupError('expected a flag at $at in "$source"');
    }
    at++;
    return unit == 0x31;
  }

  int _digits() {
    final start = at;
    while (at < source.length && _isDigit(source.codeUnitAt(at))) {
      at++;
    }
    return at - start;
  }

  static bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;
  static bool _isSign(int unit) => unit == 0x2D || unit == 0x2B;
  static bool _isSpace(int unit) =>
      unit == 0x20 || unit == 0x0A || unit == 0x09 || unit == 0x0D;
}
