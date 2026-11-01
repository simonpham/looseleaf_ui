/// Where a [PromptInput]'s request is.
///
/// Mirrors `PromptInputStatus` in upstream
/// `src/components/ui/prompt-input.tsx`.
enum PromptInputStatus {
  /// Waiting for a message.
  ready,

  /// Sent, waiting for the first words back: the submit is a stop button.
  submitted,

  /// The answer is arriving: the submit is a stop button.
  streaming,

  /// The last request failed.
  error;

  /// Whether a request is in flight (`submitted` or `streaming`).
  bool get busy => switch (this) {
    PromptInputStatus.submitted || PromptInputStatus.streaming => true,
    _ => false,
  };
}

/// Which keys send.
enum PromptInputSubmitOn {
  /// Enter sends, Shift+Enter breaks the line.
  enter,

  /// Ctrl/Cmd+Enter sends, Enter breaks the line.
  modEnter,
}

/// A character that opens suggestions: `@` anywhere, `/` only at the start.
///
/// Mirrors `PromptInputTrigger` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputTrigger {
  const PromptInputTrigger(this.char, {this.atStart = false});

  /// The character, like `@` or `/`.
  final String char;

  /// Only at the very start of the text.
  final bool atStart;
}

/// The trigger word being typed: its character, the [query] after it, and
/// where it sits in the text.
///
/// Mirrors `PromptInputActiveTrigger` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputActiveTrigger {
  const PromptInputActiveTrigger({
    required this.char,
    required this.query,
    required this.from,
    required this.to,
  });

  final String char;
  final String query;

  /// The word's start in the text.
  final int from;

  /// The caret, the word's end.
  final int to;

  /// The word typed before [caret] in [value] that starts with one of
  /// [triggers], if any.
  ///
  /// Mirrors `detectTrigger` in upstream `src/components/ui/prompt-input.tsx`.
  static PromptInputActiveTrigger? detect(
    String value,
    int caret,
    List<PromptInputTrigger> triggers,
  ) {
    if (triggers.isEmpty || caret < 1 || caret > value.length) return null;
    var start = caret;
    final space = RegExp(r'\s');
    while (start > 0 && !space.hasMatch(value[start - 1])) {
      start--;
    }
    final word = value.substring(start, caret);
    for (final trigger in triggers) {
      final char = trigger.char;
      if (char.isEmpty || !word.startsWith(char)) continue;
      if (trigger.atStart && start != 0) continue;
      return PromptInputActiveTrigger(
        char: char,
        query: word.substring(char.length),
        from: start,
        to: caret,
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is PromptInputActiveTrigger &&
      other.char == char &&
      other.query == query &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(char, query, from, to);

  @override
  String toString() => 'PromptInputActiveTrigger($char$query @ $from..$to)';
}
