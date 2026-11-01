import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';

/// A number attribute that may be a theme variable, like
/// `opacity="var(--ll-shadow-k)"`.
class InkScalar {
  const InkScalar.value(double this.value) : token = null;

  const InkScalar.token(String this.token) : value = null;

  final double? value;
  final String? token;

  static InkScalar parse(String source) {
    final text = source.trim();
    final match = RegExp(r'^var\(\s*--ll-([a-z0-9-]+)\s*\)$').firstMatch(text);
    if (match case final varMatch?) return InkScalar.token(varMatch[1] ?? '');
    final number = double.tryParse(text);
    if (number == null) throw InkMarkupError('bad number "$source"');
    return InkScalar.value(number);
  }

  /// The number, looking variables up with [lookup] (1 when unknown).
  double resolve(double? Function(String token) lookup) {
    if (value case final literal?) return literal;
    return lookup(token ?? '') ?? 1;
  }
}
