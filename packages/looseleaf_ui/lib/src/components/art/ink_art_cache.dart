import 'dart:collection';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/components/art/ink_art_frame.dart';

/// A least-recently-used cache of parsed art, like upstream `memo` in
/// `src/lib/ink/art-draw.ts`: keyed by what was drawn (name, size, seed,
/// tier, options), so every widget showing the same art shares one parse.
class InkArtCache {
  InkArtCache({this.maxEntries = 400});

  /// The cache every [InkArt] uses.
  static final InkArtCache shared = InkArtCache();

  int maxEntries;
  final LinkedHashMap<String, InkArtFrame> _entries = LinkedHashMap();

  int get length => _entries.length;

  /// The frame under [key], drawing and parsing it with [draw] on a miss.
  InkArtFrame frame(String key, ink.InkResult Function() draw) {
    final hit = _entries.remove(key);
    if (hit != null) {
      _entries[key] = hit;
      return hit;
    }
    final created = InkArtFrame.of(draw());
    _entries[key] = created;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    return created;
  }

  void clear() => _entries.clear();
}
