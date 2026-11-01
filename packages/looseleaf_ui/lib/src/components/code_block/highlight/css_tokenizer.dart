import 'dart:math' as math;

import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The lexer for CSS: at-rules, selectors, properties, values, numbers,
/// colours, functions and custom properties.
///
/// Mirrors `tokenizeCss` in upstream `src/lib/code-highlight.ts`.
class CssTokenizer {
  CssTokenizer(this.src);

  static final RegExp _queryProperty = RegExp(r'^[\w-]+(?=\s*:)');
  static final RegExp _number = RegExp(r'^-?\d*\.?\d+(?:[a-z%]+)?');
  static final RegExp _word = RegExp(r'^[\w-]+');
  static final RegExp _atRule = RegExp(r'^@[\w-]+');
  static final RegExp _property = RegExp(
    r'^(--[\w-]+|-?[a-zA-Z][\w-]*)(?=\s*:)',
  );
  static final RegExp _important = RegExp('^!important');
  static final RegExp _hex = RegExp(r'^#[\da-fA-F]{3,8}\b');
  static final RegExp _function = RegExp(r'^([\w-]+)(?=\()');
  static final RegExp _custom = RegExp(r'^--[\w-]+');
  static final RegExp _selector = RegExp(
    r'^(?:[.#][\w-]+|[a-zA-Z][\w-]*|\*|&)',
  );

  final String src;

  final CodeTokenSink _out = CodeTokenSink();
  int _i = 0;
  int _depth = 0;
  bool _inValue = false;
  int _paren = 0;

  /// Lexes [src].
  List<CodeToken> run() {
    while (_i < src.length) {
      _step(CodeScan.slice(src, _i, 300));
    }
    return _out.tokens;
  }

  bool _take(CodeTokenType type, RegExp pattern, String rest) {
    final text = CodeScan.match(pattern, rest);
    if (text == null) return false;
    _out.push(type, text);
    _i += text.length;
    return true;
  }

  void _one(CodeTokenType type, String text) {
    _out.push(type, text);
    _i++;
  }

  void _step(String rest) {
    if (_take(CodeTokenType.plain, CodeScan.whitespace, rest)) return;
    final c = rest[0];
    final query = _depth == 0 && _paren > 0;
    if (_depth == 0 && c == '(') {
      _paren++;
      return _one(CodeTokenType.punct, '(');
    }
    if (_depth == 0 && c == ')') {
      _paren = math.max(0, _paren - 1);
      return _one(CodeTokenType.punct, ')');
    }
    if (query && _take(CodeTokenType.attr, _queryProperty, rest)) return;
    if (query && _take(CodeTokenType.number, _number, rest)) return;
    if (query && _take(CodeTokenType.plain, _word, rest)) return;
    if (rest.startsWith('/*')) {
      final found = src.indexOf('*/', _i + 2);
      final end = switch (found < 0) {
        true => src.length,
        false => found + 2,
      };
      _out.push(CodeTokenType.comment, src.substring(_i, end));
      _i = end;
      return;
    }
    if (c == '"' || c == "'") {
      final end = CodeScan.stringEnd(src, _i, c);
      _out.push(CodeTokenType.string, src.substring(_i, end));
      _i = end;
      return;
    }
    if (c == '{') {
      _depth++;
      _inValue = false;
      return _one(CodeTokenType.punct, '{');
    }
    if (c == '}') {
      _depth = math.max(0, _depth - 1);
      _inValue = false;
      return _one(CodeTokenType.punct, '}');
    }
    if (c == ';') {
      _inValue = false;
      return _one(CodeTokenType.punct, ';');
    }
    if (_take(CodeTokenType.keyword, _atRule, rest)) return;
    final inRule = _depth > 0 && !_inValue;
    if (inRule && _take(CodeTokenType.attr, _property, rest)) return;
    if (c == ':' && inRule) {
      _inValue = true;
      return _one(CodeTokenType.punct, ':');
    }
    if (_inValue && _value(rest)) return;
    if (!_inValue && _take(CodeTokenType.tag, _selector, rest)) return;
    if (_take(CodeTokenType.plain, _word, rest)) return;
    _one(CodeTokenType.punct, c);
  }

  bool _value(String rest) =>
      _take(CodeTokenType.keyword, _important, rest) ||
      _take(CodeTokenType.number, _hex, rest) ||
      _take(CodeTokenType.number, _number, rest) ||
      _take(CodeTokenType.function, _function, rest) ||
      _take(CodeTokenType.variable, _custom, rest);
}
