import 'package:looseleaf_ink/src/core/core.dart';

const int _avalanche0 = 0x9e3779b9;

int _avalanche(int h) {
  h ^= h >> 16;
  h = JsMath.imul(h, 0x85ebca6b);
  h ^= h >> 13;
  h = JsMath.imul(h, 0xc2b2ae35);
  h ^= h >> 16;
  return h & 0xFFFFFFFF;
}

int _orAvalanche(int h) => switch (h) {
  0 => _avalanche0,
  _ => h,
};

/// Hashes a string or number seed to an unsigned 32-bit int.
///
/// Mirrors `hashSeed` in `src/lib/ink/rng.ts`.
int hashSeed(Object seed) {
  if (seed is num) {
    final value = seed.toDouble();
    if (!value.isFinite) return _avalanche0;
    return _orAvalanche(_avalanche(JsMath.toUint32(value)));
  }
  final text = seed.toString();
  var h = 0x811c9dc5;
  for (var i = 0; i < text.length; i++) {
    h ^= text.codeUnitAt(i);
    h = JsMath.imul(h, 0x01000193);
  }
  return _orAvalanche(_avalanche(h));
}

int _derive(int base, String name) {
  var h = (0x811c9dc5 ^ base) & 0xFFFFFFFF;
  h = JsMath.imul(h, 0x01000193);
  for (var i = 0; i < name.length; i++) {
    h ^= name.codeUnitAt(i);
    h = JsMath.imul(h, 0x01000193);
  }
  return _orAvalanche(_avalanche(h));
}

String _forkName(Object name) => switch (name) {
  final num number => JsMath.numberToString(number),
  _ => name.toString(),
};

/// A seeded mulberry32 stream: call it for a double in `[0, 1)`.
///
/// Mirrors `Rng` and `makeRng` in `src/lib/ink/rng.ts`. Forks are derived
/// from the base seed and a name, so they never disturb the parent stream.
final class Rng {
  /// A stream seeded from a string or number, hashed with [hashSeed].
  factory Rng(Object seed) => Rng.fromHash(hashSeed(seed));

  /// A stream from an already hashed seed.
  Rng.fromHash(this.seed) : _state = seed;

  /// The hashed seed this stream started from.
  final int seed;
  int _state;
  double? _spare;

  /// The next double in `[0, 1)`.
  double call() {
    _state = (_state + 0x6d2b79f5) & 0xFFFFFFFF;
    var t = _state;
    t = JsMath.imul(t ^ (t >> 15), t | 1);
    t ^= (t + JsMath.imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296;
  }

  /// A double in `[a, b)`.
  double range(double a, double b) => a + (b - a) * call();

  /// An int in `[a, b]` (upstream `rng.int`).
  int integer(int a, int b) => a + (call() * (b - a + 1)).floor();

  /// True with probability [p].
  bool chance(double p) => call() < p;

  /// -1 or 1.
  int sign() => switch (call() < 0.5) {
    true => -1,
    false => 1,
  };

  /// A random element of [items].
  T pick<T>(List<T> items) => items[(call() * items.length).floor()];

  /// A normal sample (Box-Muller, keeping the spare value).
  double gauss([double mean = 0, double sd = 1]) {
    if (_spare case final spare?) {
      _spare = null;
      return mean + sd * spare;
    }
    var u = 0.0;
    while (u == 0) {
      u = call();
    }
    final r = JsMath.sqrt(-2 * JsMath.log(u));
    final a = 2 * JsMath.pi * call();
    _spare = r * JsMath.sin(a);
    return mean + sd * r * JsMath.cos(a);
  }

  /// An independent stream derived from this seed and [name] (string or number).
  Rng fork(Object name) => Rng.fromHash(_derive(seed, _forkName(name)));
}

/// `v` limited to `[a, b]`.
double clamp(double v, double a, double b) {
  if (v < a) return a;
  if (v > b) return b;
  return v;
}

/// Linear interpolation from [a] to [b].
double lerp(double a, double b, double t) => a + (b - a) * t;

/// Smoothstep on `[0, 1]`.
double smooth(double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return t * t * (3 - 2 * t);
}
