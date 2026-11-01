import 'package:looseleaf_ui/src/theme/looseleaf_density.dart';

/// The ink knobs from Looseleaf's `Knobs` (`src/lib/ink/builder.ts`): how much
/// strokes wobble, how far fills misregister, how far felt bleeds, how wide
/// strokes are. Each is a multiplier, 1 being the default.
class LooseleafKnobs {
  const LooseleafKnobs({
    this.wobble = 1,
    this.misreg = 1,
    this.bleed = 1,
    this.width = 1,
  });

  final double wobble;
  final double misreg;
  final double bleed;
  final double width;

  /// The knobs a density draws with, like upstream `resolveKnobs`.
  LooseleafKnobs resolve(LooseleafDensity density) => switch (density) {
    LooseleafDensity.calm => LooseleafKnobs(bleed: bleed),
    LooseleafDensity.compact => LooseleafKnobs(
      wobble: wobble,
      misreg: misreg * 0.85,
      bleed: bleed,
      width: width * 0.94,
    ),
    LooseleafDensity.comfortable => this,
  };

  /// The cache key segment, like upstream `knobsKey`.
  String get key => [wobble, misreg, bleed, width].map(_round2).join(',');

  static String _round2(double value) {
    final rounded = (value * 100 + 0.5).floor() / 100;
    if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
    return rounded.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is LooseleafKnobs &&
      other.wobble == wobble &&
      other.misreg == misreg &&
      other.bleed == bleed &&
      other.width == width;

  @override
  int get hashCode => Object.hash(wobble, misreg, bleed, width);
}
