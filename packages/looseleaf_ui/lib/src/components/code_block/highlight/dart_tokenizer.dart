import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The lexer for Dart: keywords, built-in types, annotations, raw and
/// triple-quoted strings with `${…}` holes, nested block comments, calls and
/// capitalised type names.
///
/// Not in upstream `src/lib/code-highlight.ts`: written in the style of its
/// `tokenizeJs`, with the same token types and colours.
class DartTokenizer {
  DartTokenizer(this.src);

  static final Set<String> keywords =
      ('abstract as assert async await base break case catch class const '
              'continue covariant default deferred do else enum export '
              'extends extension external factory final finally for get hide '
              'if implements import in interface is late library mixin new of '
              'on operator part required rethrow return sealed set show static '
              'super switch sync this throw try type typedef var when while '
              'with yield')
          .split(' ')
          .toSet();

  /// The keywords that can never name something: the others (`on`,
  /// `show`, `required`, …) read as a name before a colon.
  static final Set<String> reserved =
      ('assert break case catch class const continue default do else enum '
              'extends final finally for if in is new rethrow return super '
              'switch this throw try var void while with')
          .split(' ')
          .toSet();

  static const Set<String> literals = {'true', 'false', 'null'};

  /// Lowercase names that are types.
  static const Set<String> builtInTypes = {
    'bool',
    'double',
    'dynamic',
    'int',
    'num',
    'void',
    'Never',
    'Object',
  };

  static final RegExp _ident = RegExp(r'^[A-Za-z_$][\w$]*');
  static final RegExp _annotation = RegExp(r'^@[A-Za-z_$][\w$.]*');
  static final RegExp _number = RegExp(
    r'^(?:0[xX][\da-fA-F_]+|\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?|\.\d[\d_]*)',
  );
  static final RegExp _string = RegExp(r'''^r?(?:'{3}|"{3}|'|")''');
  static final RegExp _operator = RegExp(
    r'^(?:=>|\.\.\.\??|\?\.\.|\?\?=?|\?\.|\.\.|[=!<>]=?|&&|\|\||[+\-*/%&|^~?:]=?|~/=?|<<=?|>>>?=?)',
  );
  static final RegExp _punct = RegExp(r'^[()\[\];,.#\\{}]');
  static final RegExp _namedArgument = RegExp(r'^\s*:(?!:)');
  static final RegExp _wordChar = RegExp(r'[\w$]');
  static final RegExp _call = RegExp(r'^\s*(?:<[^>()]*>)?\s*\(');
  static final RegExp _typeName = RegExp(
    r'^_?[A-Z](?:[A-Za-z0-9_$]*[a-z0-9])?$',
  );

  final String src;

  final CodeTokenSink _out = CodeTokenSink();
  int _i = 0;
  String _prev = '';

  /// Lexes [src].
  List<CodeToken> run() {
    while (_i < src.length) {
      _step(CodeScan.slice(src, _i, 400));
    }
    return _out.tokens;
  }

  void _push(CodeTokenType type, String text) {
    _out.push(type, text);
    _i += text.length;
  }

  void _step(String rest) {
    if (CodeScan.match(CodeScan.whitespace, rest) case final space?) {
      return _push(CodeTokenType.plain, space);
    }
    if (rest.startsWith('//')) {
      final found = src.indexOf('\n', _i);
      final end = switch (found < 0) {
        true => src.length,
        false => found,
      };
      return _push(CodeTokenType.comment, src.substring(_i, end));
    }
    if (rest.startsWith('/*')) {
      return _push(CodeTokenType.comment, src.substring(_i, _blockEnd()));
    }
    if (CodeScan.match(_string, rest) case final opener?) {
      final end = _stringEnd(_i, opener);
      _prev = '"';
      return _push(CodeTokenType.string, src.substring(_i, end));
    }
    if (CodeScan.match(_annotation, rest) case final annotation?) {
      _prev = annotation;
      return _push(CodeTokenType.attr, annotation);
    }
    if (CodeScan.match(_number, rest) case final number?) {
      _prev = number;
      return _push(CodeTokenType.number, number);
    }
    if (CodeScan.match(_ident, rest) case final word?) {
      final after = CodeScan.slice(src, _i + word.length, 60);
      final type = _wordType(word, after);
      _prev = word;
      return _push(type, word);
    }
    if (CodeScan.match(_operator, rest) case final op?) {
      _prev = op;
      return _push(CodeTokenType.punct, op);
    }
    if (CodeScan.match(_punct, rest) case final mark?) {
      _prev = mark;
      return _push(CodeTokenType.punct, mark);
    }
    _push(CodeTokenType.plain, rest[0]);
  }

  /// Where the block comment at the cursor ends; Dart's nest.
  int _blockEnd() {
    var depth = 0;
    var i = _i;
    while (i < src.length) {
      if (src.startsWith('/*', i)) {
        depth++;
        i += 2;
        continue;
      }
      if (src.startsWith('*/', i)) {
        depth--;
        i += 2;
        if (depth == 0) return i;
        continue;
      }
      i++;
    }
    return src.length;
  }

  /// Where the string at [start] opened by [opener] (`r`, then one or three quotes)
  /// ends, skipping escapes (unless raw) and `${…}` holes.
  int _stringEnd(int start, String opener) {
    final raw = opener.startsWith('r');
    final quote = opener.substring(switch (raw) {
      true => 1,
      false => 0,
    });
    final multiline = quote.length == 3;
    var i = start + opener.length;
    while (i < src.length) {
      final c = src[i];
      if (c == r'\' && !raw) {
        i += 2;
        continue;
      }
      if (src.startsWith(quote, i)) return i + quote.length;
      if (c == '\n' && !multiline) return i;
      if (c == r'$' && !raw && i + 1 < src.length && src[i + 1] == '{') {
        i = _holeEnd(i + 2);
        continue;
      }
      i++;
    }
    return src.length;
  }

  int _holeEnd(int start) {
    var depth = 1;
    var i = start;
    while (i < src.length && depth > 0) {
      if (CodeScan.match(_string, CodeScan.slice(src, i, 4)) case final opener?
          when i == start || !_wordChar.hasMatch(src[i - 1])) {
        i = _stringEnd(i, opener);
        continue;
      }
      if (src[i] == '{') depth++;
      if (src[i] == '}') depth--;
      i++;
    }
    return i;
  }

  CodeTokenType _wordType(String word, String after) {
    if (literals.contains(word)) return CodeTokenType.literal;
    if (_prev == '.' || _prev == '?.') return _memberType(word, after);
    if (_namedArgument.hasMatch(after) && !reserved.contains(word)) {
      return CodeTokenType.plain;
    }
    if (keywords.contains(word)) return CodeTokenType.keyword;
    if (builtInTypes.contains(word)) return CodeTokenType.type;
    return _memberType(word, after);
  }

  CodeTokenType _memberType(String word, String after) {
    if (_typeName.hasMatch(word)) return CodeTokenType.type;
    if (_call.hasMatch(after)) return CodeTokenType.function;
    return CodeTokenType.plain;
  }
}
