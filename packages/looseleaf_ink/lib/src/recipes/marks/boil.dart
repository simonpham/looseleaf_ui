import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

final List<Knobs> _table = [
  Knobs(),
  Knobs(wobble: 1.3, misreg: 1.7, bleed: 1.18, width: 0.96),
  Knobs(wobble: 0.78, misreg: 0.5, bleed: 0.86, width: 1.05),
  Knobs(wobble: 1.12, misreg: 1.3, bleed: 1.06, width: 0.98),
];

/// How many distinct boil frames there are.
///
/// Mirrors `BOIL_MAX_FRAMES` in `src/lib/ink/recipes/boil-ink.ts`.
final int boilMaxFrames = _table.length;

/// The knobs of boil [frame] (line boil: the same drawing redrawn with
/// slightly different hands), scaled by [strength].
///
/// Mirrors `boilKnobs` in `src/lib/ink/recipes/boil-ink.ts`.
Knobs boilKnobs(int frame, [double strength = 1]) {
  final k = _table[((frame % _table.length) + _table.length) % _table.length];
  final s = math.max(0, strength);
  double at(double v) => math.max(0.05, 1 + (v - 1) * s);
  return Knobs(
    wobble: at(k.wobble),
    misreg: at(k.misreg),
    bleed: at(k.bleed),
    width: at(k.width),
  );
}

/// The seed of boil [frame]: frame 0 keeps [seed].
///
/// Mirrors `boilSeed` in `src/lib/ink/recipes/boil-ink.ts`.
String boilSeed(Object seed, int frame) => switch (frame) {
  0 => switch (seed) {
    final num v => JsMath.numberToString(v),
    _ => '$seed',
  },
  _ => switch (seed) {
    final num v => '${JsMath.numberToString(v)}~$frame',
    _ => '$seed~$frame',
  },
};
