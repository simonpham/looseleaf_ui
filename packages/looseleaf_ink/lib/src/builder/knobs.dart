import 'package:looseleaf_ink/src/core/core.dart';

/// The theme's global ink knobs: wobble, misregistration, bleed and width.
///
/// Mirrors `Knobs` in `src/lib/ink/builder.ts`.
final class Knobs {
  /// Knobs, all 1 by default.
  Knobs({this.wobble = 1, this.misreg = 1, this.bleed = 1, this.width = 1});

  double wobble;
  double misreg;
  double bleed;
  double width;

  /// A copy with some fields replaced.
  Knobs copyWith({
    double? wobble,
    double? misreg,
    double? bleed,
    double? width,
  }) => Knobs(
    wobble: wobble ?? this.wobble,
    misreg: misreg ?? this.misreg,
    bleed: bleed ?? this.bleed,
    width: width ?? this.width,
  );

  /// The knobs as upstream's object shape.
  Map<String, double> toJson() => {
    'wobble': wobble,
    'misreg': misreg,
    'bleed': bleed,
    'width': width,
  };

  /// Stable memo key, two decimals each (`knobsKey` in `recipes/index.ts`).
  String get key {
    String f(double v) => JsMath.numberToString(JsMath.round(v * 100) / 100);
    return '${f(wobble)},${f(misreg)},${f(bleed)},${f(width)}';
  }
}
