import 'dart:math' as math;

/// Scores how well [search] abbreviates [value] (with [keywords] appended),
/// from 0 (no match) to 1 (the whole value, typed in full): matches that
/// run on, start words or keep the case score higher, skipped letters and
/// transposed ones lower.
///
/// A port of cmdk's `commandScore` (`command-score.ts`, after Superhuman's
/// command-score), the default filter of upstream `Command`.
double commandScore(String value, String search, List<String> keywords) {
  final string = switch (keywords.isEmpty) {
    true => value,
    false => '$value ${keywords.join(' ')}',
  };
  return _CommandScore(
    string,
    search,
    _format(string),
    _format(search),
  ).score(0, 0);
}

String _format(String input) => input.toLowerCase().replaceAll(_space, ' ');

final RegExp _gap = RegExp(r'[\\/_+.#"@\[\(\{&]');
final RegExp _space = RegExp(r'[\s-]');

class _CommandScore {
  _CommandScore(this.string, this.abbreviation, this.lower, this.lowerAbbr);

  /// A run of matches; a full run scores 1.
  static const double continueMatch = 1;

  /// A match starting a word after a space or hyphen.
  static const double spaceWordJump = 0.9;

  /// A match starting a word after a slash, bracket, dot and the like.
  static const double nonSpaceWordJump = 0.8;

  /// Any other match.
  static const double characterJump = 0.17;

  /// Two letters typed the wrong way round.
  static const double transposition = 0.1;

  /// Per skipped character or word.
  static const double penaltySkipped = 0.999;

  /// A match in the other case.
  static const double penaltyCaseMismatch = 0.9999;

  /// The value goes on past the search.
  static const double penaltyNotComplete = 0.99;

  final String string;
  final String abbreviation;
  final String lower;
  final String lowerAbbr;
  final Map<(int, int), double> _memo = {};

  String _at(String text, int index) =>
      switch (index >= 0 && index < text.length) {
        true => text[index],
        false => '',
      };

  double score(int stringIndex, int abbrIndex) {
    if (abbrIndex >= abbreviation.length) {
      return switch (stringIndex == string.length) {
        true => continueMatch,
        false => penaltyNotComplete,
      };
    }
    final key = (stringIndex, abbrIndex);
    if (_memo[key] case final memoized?) return memoized;
    final char = lowerAbbr[abbrIndex];
    var index = lower.indexOf(char, stringIndex);
    var high = 0.0;
    while (index >= 0) {
      var current = score(index + 1, abbrIndex + 1);
      if (current > high) {
        current *= _jump(stringIndex, index);
        if (_at(string, index) != _at(abbreviation, abbrIndex)) {
          current *= penaltyCaseMismatch;
        }
      }
      final next = _at(lowerAbbr, abbrIndex + 1);
      final before = _at(lower, index - 1);
      final transposed = current < transposition && before == next;
      final doubled = next == char && before != char;
      if (transposed || doubled) {
        final swapped = score(index + 1, abbrIndex + 2);
        if (swapped * transposition > current) {
          current = swapped * transposition;
        }
      }
      if (current > high) high = current;
      index = lower.indexOf(char, index + 1);
    }
    _memo[key] = high;
    return high;
  }

  double _jump(int stringIndex, int index) {
    if (index == stringIndex) return continueMatch;
    final before = _at(string, index - 1);
    final skipped = string.substring(stringIndex, index - 1);
    if (_gap.hasMatch(before)) {
      return nonSpaceWordJump *
          _skipPenalty(_gap.allMatches(skipped).length, stringIndex);
    }
    if (_space.hasMatch(before)) {
      return spaceWordJump *
          _skipPenalty(_space.allMatches(skipped).length, stringIndex);
    }
    return characterJump * _skipPenalty(index - stringIndex, stringIndex);
  }

  static double _skipPenalty(int skipped, int stringIndex) =>
      switch (skipped > 0 && stringIndex > 0) {
        true => math.pow(penaltySkipped, skipped).toDouble(),
        false => 1,
      };
}
