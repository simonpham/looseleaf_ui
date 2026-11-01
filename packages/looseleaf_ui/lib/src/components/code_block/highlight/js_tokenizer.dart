import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

enum _JsMode { js, tag, children }

class _Frame {
  _Frame(this.mode, this.depth);

  final _JsMode mode;
  int depth;
}

/// The lexer for TypeScript and JavaScript, with JSX tags, attributes and
/// children when [jsx].
///
/// Mirrors `tokenizeJs` in upstream `src/lib/code-highlight.ts`.
class JsTokenizer {
  JsTokenizer(this.src, {required this.jsx});

  static final Set<String> keywords =
      ('abstract as async await break case catch class const continue '
              'debugger declare default delete do else enum export extends '
              'finally for from function get if implements import in infer '
              'instanceof interface is keyof let namespace new of override '
              'private protected public readonly return satisfies set static '
              'super switch this throw try type typeof var void while with '
              'yield')
          .split(' ')
          .toSet();

  static const Set<String> literals = {
    'true',
    'false',
    'null',
    'undefined',
    'NaN',
    'Infinity',
  };

  static final RegExp _ident = RegExp(r'^[A-Za-z_$][\w$]*');
  static final RegExp _number = RegExp(
    r'^(?:0[xX][\da-fA-F_]+|0[bB][01_]+|\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?n?|\.\d[\d_]*)',
  );
  static final RegExp _operator = RegExp(
    r'^(?:=>|\.\.\.|\?\?=?|\?\.|[=!<>]=?=?|&&=?|\|\|=?|[+\-*/%&|^~?:]=?|<<=?|>>>?=?)',
  );
  static final RegExp _punct = RegExp(r'^[()\[\];,.@#\\{}]');
  static final RegExp _childStop = RegExp('[<{]');
  static final RegExp _closeTag = RegExp(r'^</([A-Za-z_$][\w$.-]*)?\s*>');
  static final RegExp _openTag = RegExp(r'^<([A-Za-z_$][\w$.-]*)?');
  static final RegExp _jsxOpen = RegExp(r'^<([A-Za-z_$][\w$.-]*)?(?=[\s/>])');
  static final RegExp _attr = RegExp(r'^[\w$:.-]+');
  static final RegExp _exprEnd = RegExp(r'[(=,:?{\[&|!]$');
  static final RegExp _call = RegExp(r'^\s*(?:<[^>()]*>)?\s*\(');
  static final RegExp _upper = RegExp('^[A-Z]');
  static final RegExp _typeName = RegExp('^[A-Z][a-z0-9]');

  final String src;
  final bool jsx;

  final CodeTokenSink _out = CodeTokenSink();
  final List<_Frame> _modes = [_Frame(_JsMode.js, 0)];
  int _i = 0;
  String _prev = '';

  /// Lexes [src].
  List<CodeToken> run() {
    while (_i < src.length) {
      final top = _modes.last;
      final rest = CodeScan.slice(src, _i, 400);
      switch (top.mode) {
        case _JsMode.children:
          _children(rest);
        case _JsMode.tag:
          _tag(rest);
        case _JsMode.js:
          _js(top, rest);
      }
    }
    return _out.tokens;
  }

  bool get _startsExpression =>
      _prev == '' ||
      _exprEnd.hasMatch(_prev) ||
      _prev == '=>' ||
      _prev == 'return' ||
      _prev == '&&' ||
      _prev == '||' ||
      _prev == '??';

  void _openJs() {
    _out.push(CodeTokenType.punct, '{');
    _modes.add(_Frame(_JsMode.js, 1));
    _prev = '{';
    _i++;
  }

  void _children(String rest) {
    final found = src.indexOf(_childStop, _i);
    final stop = switch (found < 0) {
      true => src.length,
      false => found,
    };
    if (stop > _i) {
      _out.push(CodeTokenType.plain, src.substring(_i, stop));
      _i = stop;
      return;
    }
    if (src[_i] == '{') return _openJs();
    if (_closeTag.firstMatch(rest) case final close?) {
      _out
        ..push(CodeTokenType.punct, '</')
        ..push(CodeTokenType.tag, close.group(1) ?? '')
        ..push(CodeTokenType.punct, '>');
      _modes.removeLast();
      _prev = '>';
      _i += close.group(0)?.length ?? 0;
      return;
    }
    if (_openTag.firstMatch(rest) case final open?) {
      _out
        ..push(CodeTokenType.punct, '<')
        ..push(CodeTokenType.tag, open.group(1) ?? '');
      _modes.add(_Frame(_JsMode.tag, 0));
      _i += open.group(0)?.length ?? 0;
      return;
    }
    _out.push(CodeTokenType.plain, '<');
    _i++;
  }

  void _tag(String rest) {
    if (CodeScan.match(CodeScan.whitespace, rest) case final space?) {
      _out.push(CodeTokenType.plain, space);
      _i += space.length;
      return;
    }
    if (rest.startsWith('/>')) {
      _out.push(CodeTokenType.punct, '/>');
      _modes.removeLast();
      _prev = '>';
      _i += 2;
      return;
    }
    final c = rest[0];
    if (c == '>') {
      _out.push(CodeTokenType.punct, '>');
      _modes
        ..removeLast()
        ..add(_Frame(_JsMode.children, 0));
      _i++;
      return;
    }
    if (c == '"' || c == "'") {
      final end = CodeScan.stringEnd(src, _i, c);
      _out.push(CodeTokenType.string, src.substring(_i, end));
      _i = end;
      return;
    }
    if (c == '{') return _openJs();
    if (CodeScan.match(_attr, rest) case final attr?) {
      _out.push(CodeTokenType.attr, attr);
      _i += attr.length;
      return;
    }
    if (c == '=') {
      _out.push(CodeTokenType.punct, '=');
      _i++;
      return;
    }
    _out.push(CodeTokenType.plain, c);
    _i++;
  }

  void _js(_Frame top, String rest) {
    if (CodeScan.match(CodeScan.whitespace, rest) case final space?) {
      _out.push(CodeTokenType.plain, space);
      _i += space.length;
      return;
    }
    if (rest.startsWith('//')) {
      final found = src.indexOf('\n', _i);
      final end = switch (found < 0) {
        true => src.length,
        false => found,
      };
      _out.push(CodeTokenType.comment, src.substring(_i, end));
      _i = end;
      return;
    }
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
    final c = rest[0];
    if (c == '"' || c == "'" || c == '`') {
      final end = switch (c) {
        '`' => CodeScan.templateEnd(src, _i),
        _ => CodeScan.stringEnd(src, _i, c),
      };
      _out.push(CodeTokenType.string, src.substring(_i, end));
      _i = end;
      _prev = c;
      return;
    }
    if (top.depth > 0 || _modes.length > 1) {
      if (c == '{') top.depth++;
      if (c == '}') {
        top.depth--;
        if (top.depth == 0 && _modes.length > 1) {
          _out.push(CodeTokenType.punct, '}');
          _modes.removeLast();
          _prev = '}';
          _i++;
          return;
        }
      }
    }
    if (jsx && c == '<' && _startsExpression) {
      if (_jsxOpen.firstMatch(rest) case final open?) {
        _out
          ..push(CodeTokenType.punct, '<')
          ..push(CodeTokenType.tag, open.group(1) ?? '');
        _modes.add(_Frame(_JsMode.tag, 0));
        _i += open.group(0)?.length ?? 0;
        return;
      }
    }
    if (CodeScan.match(_number, rest) case final number?) {
      _out.push(CodeTokenType.number, number);
      _i += number.length;
      _prev = number;
      return;
    }
    if (CodeScan.match(_ident, rest) case final word?) {
      final after = CodeScan.slice(src, _i + word.length, 60);
      _out.push(_wordType(word, after), word);
      _i += word.length;
      _prev = word;
      return;
    }
    if (CodeScan.match(_operator, rest) case final op?) {
      _out.push(CodeTokenType.punct, op);
      _i += op.length;
      _prev = op;
      return;
    }
    if (CodeScan.match(_punct, rest) case final mark?) {
      _out.push(CodeTokenType.punct, mark);
      _i++;
      _prev = mark;
      return;
    }
    _out.push(CodeTokenType.plain, c);
    _i++;
  }

  CodeTokenType _wordType(String word, String after) {
    if (literals.contains(word)) return CodeTokenType.literal;
    if (keywords.contains(word) && _prev != '.') return CodeTokenType.keyword;
    if (_call.hasMatch(after) && !_upper.hasMatch(word)) {
      return CodeTokenType.function;
    }
    if (_typeName.hasMatch(word)) return CodeTokenType.type;
    return CodeTokenType.plain;
  }
}
