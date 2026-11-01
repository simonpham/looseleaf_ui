import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The lexer for shell sessions: prompts, commands, flags, variables,
/// strings, operators and comments.
///
/// Mirrors `tokenizeBash` in upstream `src/lib/code-highlight.ts`.
class BashTokenizer {
  BashTokenizer(this.src);

  static final Set<String> keywords =
      ('if then else elif fi for while until do done case esac in function '
              'select time export local return exit source alias unset')
          .split(' ')
          .toSet();

  static final RegExp _blank = RegExp(r'^[ \t]+');
  static final RegExp _space = RegExp(r'\s');
  static final RegExp _prompt = RegExp(r'^[$>] ');
  static final RegExp _variable = RegExp(
    r'^\$(?:\{[^}]*\}|[A-Za-z_]\w*|[0-9@#?$!*-])',
  );
  static final RegExp _operator = RegExp(r'^(?:&&|\|\||[|;&]|>>?|<<?|2>&1)');
  static final RegExp _flag = RegExp(r'^--?[A-Za-z][\w-]*(?:=[^\s]*)?');
  static final RegExp _word = RegExp(r'''^[^\s|;&<>"'$#]+''');
  static final RegExp _digits = RegExp(r'^\d+$');
  static const Set<String> _redirects = {'>', '>>', '<', '<<'};

  final String src;

  final CodeTokenSink _out = CodeTokenSink();
  int _i = 0;
  bool _command = true;

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

  void _step(String rest) {
    final c = rest[0];
    final lineStart = _i == 0 || src[_i - 1] == '\n';
    if (c == '\n') {
      _command = true;
      return _push(CodeTokenType.plain, '\n');
    }
    if (CodeScan.match(_blank, rest) case final blank?) {
      return _push(CodeTokenType.plain, blank);
    }
    if (c == '#' && (_i == 0 || _space.hasMatch(src[_i - 1]))) {
      final found = src.indexOf('\n', _i);
      final end = switch (found < 0) {
        true => src.length,
        false => found,
      };
      return _push(CodeTokenType.comment, src.substring(_i, end));
    }
    if (_command && lineStart) {
      if (CodeScan.match(_prompt, rest) case final prompt?) {
        return _push(CodeTokenType.punct, prompt);
      }
    }
    if (c == '"' || c == "'") {
      final end = CodeScan.stringEnd(src, _i, c);
      _command = false;
      return _push(CodeTokenType.string, src.substring(_i, end));
    }
    if (CodeScan.match(_variable, rest) case final variable?) {
      _command = false;
      return _push(CodeTokenType.variable, variable);
    }
    if (CodeScan.match(_operator, rest) case final op?) {
      _command = !_redirects.contains(op);
      return _push(CodeTokenType.punct, op);
    }
    if (!_command) {
      if (CodeScan.match(_flag, rest) case final flag?) {
        return _push(CodeTokenType.attr, flag);
      }
    }
    if (CodeScan.match(_word, rest) case final word?) {
      final type = _wordType(word);
      _command = false;
      return _push(type, word);
    }
    _push(CodeTokenType.plain, c);
  }

  CodeTokenType _wordType(String word) {
    if (_command || keywords.contains(word)) return CodeTokenType.keyword;
    if (_digits.hasMatch(word)) return CodeTokenType.number;
    return CodeTokenType.plain;
  }
}
