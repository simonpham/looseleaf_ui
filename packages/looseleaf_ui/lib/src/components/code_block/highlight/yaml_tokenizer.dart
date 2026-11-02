import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The lexer for YAML: keys, list dashes, quoted strings, numbers, literals,
/// anchors and aliases, document markers and comments.
///
/// Not in upstream `src/lib/code-highlight.ts`: written in the style of its
/// `tokenizeJson`, with the same token types and colours.
class YamlTokenizer {
  YamlTokenizer(this.src);

  static final RegExp _blank = RegExp(r'^[ \t]+');
  static final RegExp _marker = RegExp(r'^(?:---|\.\.\.)(?=\s|$)');
  static final RegExp _dash = RegExp(r'^-(?=[ \t\n]|$)');
  static final RegExp _key = RegExp(
    r'''^(?:"[^"\n]*"|'[^'\n]*'|[^\s#:,\[\]{}"'][^#:\n]*?)(?=[ \t]*:(?:[ \t\n]|$))''',
  );
  static final RegExp _anchor = RegExp(r'^[&*][^\s,\[\]{}]+');
  static final RegExp _tag = RegExp(r'^![^\s,\[\]{}]*');
  static final RegExp _scalar = RegExp(r'^[^\s#,\[\]{}][^\n#,\[\]{}]*');
  static final RegExp _number = RegExp(
    r'^[-+]?(?:0x[\da-fA-F]+|0o[0-7]+|\d[\d_]*(?:\.\d*)?(?:[eE][+-]?\d+)?|\.(?:inf|Inf|INF|nan|NaN|NAN))$',
  );
  static const Set<String> _literals = {
    'true',
    'false',
    'True',
    'False',
    'TRUE',
    'FALSE',
    'yes',
    'no',
    'null',
    'Null',
    'NULL',
    '~',
  };

  final String src;

  final CodeTokenSink _out = CodeTokenSink();
  int _i = 0;

  /// Lexes [src].
  List<CodeToken> run() {
    while (_i < src.length) {
      _step(CodeScan.slice(src, _i, 300));
    }
    return _out.tokens;
  }

  void _push(CodeTokenType type, String text) {
    _out.push(type, text);
    _i += text.length;
  }

  bool get _lineStart {
    var k = _i - 1;
    while (k >= 0 && (src[k] == ' ' || src[k] == '\t')) {
      k--;
    }
    return k < 0 || src[k] == '\n';
  }

  bool get _afterDash {
    var k = _i - 1;
    while (k >= 0 && (src[k] == ' ' || src[k] == '\t')) {
      k--;
    }
    return k >= 0 && src[k] == '-' && (k == 0 || src[k - 1] != '-');
  }

  void _step(String rest) {
    final c = rest[0];
    if (c == '\n') return _push(CodeTokenType.plain, '\n');
    if (CodeScan.match(_blank, rest) case final blank?) {
      return _push(CodeTokenType.plain, blank);
    }
    if (c == '#' && (_i == 0 || src[_i - 1].trim().isEmpty)) {
      final found = src.indexOf('\n', _i);
      final end = switch (found < 0) {
        true => src.length,
        false => found,
      };
      return _push(CodeTokenType.comment, src.substring(_i, end));
    }
    final keyPosition =
        _lineStart || _afterDash || _prevIs('{') || _prevIs(',');
    if (_lineStart) {
      if (CodeScan.match(_marker, rest) case final marker?) {
        return _push(CodeTokenType.punct, marker);
      }
    }
    if (CodeScan.match(_dash, rest) case final dash? when _lineStart) {
      return _push(CodeTokenType.punct, dash);
    }
    if (keyPosition) {
      if (CodeScan.match(_key, rest) case final key?) {
        return _push(CodeTokenType.attr, key);
      }
    }
    if (c == '"' || c == "'") {
      return _push(
        CodeTokenType.string,
        src.substring(_i, CodeScan.stringEnd(src, _i, c)),
      );
    }
    if (CodeScan.match(_anchor, rest) case final anchor?) {
      return _push(CodeTokenType.variable, anchor);
    }
    if (CodeScan.match(_tag, rest) case final tag?) {
      return _push(CodeTokenType.type, tag);
    }
    if (':,[]{}|>'.contains(c)) return _push(CodeTokenType.punct, c);
    if (CodeScan.match(_scalar, rest) case final scalar?) {
      final value = scalar.trimRight();
      return _push(_scalarType(value), value);
    }
    _push(CodeTokenType.plain, c);
  }

  bool _prevIs(String mark) {
    var k = _i - 1;
    while (k >= 0 && (src[k] == ' ' || src[k] == '\t')) {
      k--;
    }
    return k >= 0 && src[k] == mark;
  }

  CodeTokenType _scalarType(String value) {
    if (_literals.contains(value)) return CodeTokenType.literal;
    if (_number.hasMatch(value)) return CodeTokenType.number;
    return CodeTokenType.plain;
  }
}
