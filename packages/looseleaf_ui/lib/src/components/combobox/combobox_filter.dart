/// Scores how well an item matches the search: 0 hides it, more is a
/// better match.
typedef ComboboxFilter = double Function(
  String value,
  String search,
  List<String> keywords,
);

/// The default filter: a case-insensitive match of [search] in the value
/// or a keyword, scored higher at the start of a word, lower when the
/// letters only appear in order.
///
/// Approximates cmdk's `defaultFilter` (command-score), which upstream
/// `src/components/ui/combobox.tsx` uses.
double comboboxDefaultFilter(
  String value,
  String search,
  List<String> keywords,
) {
  final query = search.trim().toLowerCase();
  if (query.isEmpty) return 1;
  var best = 0.0;
  for (final candidate in [value, ...keywords]) {
    final text = candidate.toLowerCase();
    final score = _score(text, query);
    if (score > best) best = score;
  }
  return best;
}

double _score(String text, String query) {
  final at = text.indexOf(query);
  if (at == 0) return 1;
  if (at > 0) {
    final wordStart = !RegExp('[a-z0-9]').hasMatch(text[at - 1]);
    return switch (wordStart) {
      true => 0.9,
      false => 0.7,
    };
  }
  var index = 0;
  for (final char in query.split('')) {
    final found = text.indexOf(char, index);
    if (found < 0) return 0;
    index = found + 1;
  }
  return 0.3;
}
