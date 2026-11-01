import 'package:looseleaf_ink/looseleaf_ink.dart' show JsMath, Rng, clamp;

/// How far one word sits off the baseline and how light it is written.
///
/// Mirrors `word` in upstream `src/components/ui/handwritten.tsx`: `--jy`
/// and `--jo` (`--jr` is drawn too, to keep the stream, but upstream no
/// longer applies it).
class HandwrittenJitter {
  const HandwrittenJitter({required this.dy, required this.opacity});

  /// The jitter of word [index] of a text written with [seed] at strength
  /// [k] (strength after density).
  factory HandwrittenJitter.of(String seed, int index, double k) {
    final rng = Rng(seed).fork(index);
    final dy = clamp(rng.gauss(0, 0.55) * 1.5 * k, -1.6, 1.6);
    rng.gauss(0, 0.6);
    final opacity = 1 - rng.range(0, 0.12) * k;
    return HandwrittenJitter(
      dy: double.parse(JsMath.toFixed(dy, 2)),
      opacity: double.parse(JsMath.toFixed(opacity, 2)),
    );
  }

  /// The drop from the baseline in px (`--jy`).
  final double dy;

  /// The ink's opacity (`--jo`).
  final double opacity;
}
