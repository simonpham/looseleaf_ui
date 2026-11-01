/// Finds options by typed letters, like a native select: letters typed
/// within [timeout] of each other build one search, and a single letter
/// typed again cycles through the options starting with it.
class NativeSelectTypeahead {
  NativeSelectTypeahead({this.timeout = const Duration(milliseconds: 600)});

  /// How long a search waits for the next letter.
  final Duration timeout;

  String _query = '';
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  /// The index in [labels] the letter [char] leads to, searching after
  /// [current] and skipping indexes [enabled] rejects, or null.
  int? find(
    String char,
    List<String> labels,
    int current, {
    required bool Function(int index) enabled,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final fresh = at.difference(_last) > timeout;
    _last = at;
    final lower = char.toLowerCase();
    _query = switch (fresh) {
      true => lower,
      false => _query + lower,
    };
    final repeated =
        _query.length > 1 && _query.split('').every((c) => c == lower);
    final query = switch (repeated) {
      true => lower,
      false => _query,
    };
    final start = switch (query.length == 1) {
      true => current + 1,
      false => current,
    };
    for (var step = 0; step < labels.length; step++) {
      final index = (start + step) % labels.length;
      if (index < 0 || !enabled(index)) continue;
      if (labels[index].toLowerCase().startsWith(query)) return index;
    }
    return null;
  }
}
