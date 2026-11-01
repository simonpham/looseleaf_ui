import 'dart:math' as math;

import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The tokens a lexer writes: neighbouring plain and punctuation runs merge.
///
/// Mirrors `push` in upstream `src/lib/code-highlight.ts`.
class CodeTokenSink {
  /// The tokens written so far.
  final List<CodeToken> tokens = [];

  /// Appends [text] as [type]; skips empty text.
  void push(CodeTokenType type, String text) {
    if (text.isEmpty) return;
    final mergeable =
        type == CodeTokenType.plain || type == CodeTokenType.punct;
    if (tokens.lastOrNull case final last?
        when mergeable && last.type == type) {
      tokens[tokens.length - 1] = CodeToken(type, last.text + text);
      return;
    }
    tokens.add(CodeToken(type, text));
  }
}

/// Lexing helpers shared by the languages of upstream
/// `src/lib/code-highlight.ts`.
abstract final class CodeScan {
  /// Leading whitespace (`WS`).
  static final RegExp whitespace = RegExp(r'^\s+');

  /// `src.slice(start, start + length)`.
  static String slice(String src, int start, int length) =>
      src.substring(start, math.min(src.length, start + length));

  /// The whole match of [pattern] at the start of [rest], or null.
  static String? match(RegExp pattern, String rest) =>
      pattern.firstMatch(rest)?.group(0);

  /// Where the string opened by [quote] at [start] ends: after its closing
  /// quote, or at the line break for a non-template string.
  static int stringEnd(String src, int start, String quote) {
    var i = start + 1;
    while (i < src.length) {
      final c = src[i];
      if (c == r'\') {
        i += 2;
        continue;
      }
      if (c == quote) return i + 1;
      if (c == '\n' && quote != '`') return i;
      i++;
    }
    return src.length;
  }

  /// Where the template literal at [start] ends, skipping `${…}` holes and
  /// nested templates.
  static int templateEnd(String src, int start) {
    var i = start + 1;
    while (i < src.length) {
      final c = src[i];
      if (c == r'\') {
        i += 2;
        continue;
      }
      if (c == '`') return i + 1;
      if (c == r'$' && i + 1 < src.length && src[i + 1] == '{') {
        i = _holeEnd(src, i + 2);
        continue;
      }
      i++;
    }
    return src.length;
  }

  static int _holeEnd(String src, int start) {
    var depth = 1;
    var i = start;
    while (i < src.length && depth > 0) {
      final d = src[i];
      if (d == '`') {
        i = templateEnd(src, i);
        continue;
      }
      if (d == '{') depth++;
      if (d == '}') depth--;
      i++;
    }
    return i;
  }
}
