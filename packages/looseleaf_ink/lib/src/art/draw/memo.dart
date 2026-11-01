final Map<String, Object?> _cache = {};

/// A least-recently-used cache of drawn art, keyed by [key], keeping at
/// most [max] entries.
///
/// Mirrors `memo` in `src/lib/ink/art-draw.ts`.
T memo<T>(String key, T Function() make, [int max = 400]) {
  if (_cache.containsKey(key)) {
    final hit = _cache.remove(key);
    _cache[key] = hit;
    if (hit is T) return hit;
  }
  final v = make();
  _cache[key] = v;
  if (_cache.length > max) _cache.remove(_cache.keys.first);
  return v;
}
