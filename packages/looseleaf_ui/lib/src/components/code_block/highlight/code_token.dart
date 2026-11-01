/// What a piece of code is, which picks its colour.
///
/// Mirrors `TokenType` in upstream `src/lib/code-highlight.ts`.
enum CodeTokenType {
  plain,
  comment,
  string,
  keyword,
  literal,
  number,
  function,
  type,
  tag,
  attr,
  variable,
  punct,
}

/// A run of source [text] of one [type].
///
/// Mirrors `Token` in upstream `src/lib/code-highlight.ts`.
class CodeToken {
  const CodeToken(this.type, this.text);

  final CodeTokenType type;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is CodeToken && other.type == type && other.text == text;

  @override
  int get hashCode => Object.hash(type, text);

  @override
  String toString() => '${type.name}:$text';
}
