import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

String _show(List<CodeToken> tokens) => [
  for (final token in tokens)
    if (token.text.trim() case final text when text.isNotEmpty)
      '${token.type.name}:$text',
].join(' ');

void main() {
  group('dart', () {
    List<CodeToken> lex(String code) =>
        CodeTokenizer.tokenize(code, CodeLang.dart);

    test('resolves from names and file names', () {
      expect(CodeLang.parse('Dart'), CodeLang.dart);
      expect(CodeLang.fromFileName('lib/main.dart'), CodeLang.dart);
    });

    test('keywords, types, calls and literals', () {
      expect(
        _show(lex('final value = Spacing.d16;')),
        'keyword:final plain:value punct:= type:Spacing punct:. plain:d16 punct:;',
      );
      expect(
        _show(lex('void main() => runApp(const App(on: true));')),
        'type:void function:main punct:() punct:=> function:runApp punct:( '
        'keyword:const type:App punct:( plain:on punct:: literal:true punct:));',
      );
      expect(
        _show(lex('List<int> xs = items.map<int>((x) => x).toList();')),
        'type:List punct:< type:int punct:> plain:xs punct:= plain:items '
        'punct:. function:map punct:< type:int punct:>(( plain:x punct:) punct:=> '
        'plain:x punct:). function:toList punct:();',
      );
    });

    test('annotations, numbers and comments', () {
      expect(
        _show(lex('@override\nint get n => 0x1F; // done\n/* a /* b */ c */')),
        'attr:@override type:int keyword:get plain:n punct:=> number:0x1F '
        'punct:; comment:// done comment:/* a /* b */ c */',
      );
    });

    test('strings: raw, interpolated and triple-quoted', () {
      expect(
        lex(r"r'\d$x'").single,
        const CodeToken(CodeTokenType.string, r"r'\d$x'"),
      );
      expect(
        lex(r"'a ${b.map((c) => '}')} d'").single.type,
        CodeTokenType.string,
      );
      expect(
        lex("'''one\n'two'\nthree'''").single,
        const CodeToken(CodeTokenType.string, "'''one\n'two'\nthree'''"),
      );
      expect(_show(lex("'open\nx")), "string:'open plain:x");
    });

    test('a member or named argument named like a keyword stays plain', () {
      expect(_show(lex('a.default')), 'plain:a punct:. plain:default');
      expect(
        _show(lex('f(required: 1); default: x;')),
        'function:f punct:( plain:required punct:: number:1 punct:); '
        'keyword:default punct:: plain:x punct:;',
      );
    });
  });

  group('yaml', () {
    List<CodeToken> lex(String code) =>
        CodeTokenizer.tokenize(code, CodeLang.yaml);

    test('resolves from names and file names', () {
      expect(CodeLang.parse('yml'), CodeLang.yaml);
      expect(CodeLang.fromFileName('pubspec.yaml'), CodeLang.yaml);
    });

    test('keys, scalars, numbers and literals', () {
      expect(
        _show(
          lex(
            'name: gallery # app\nversion: 1.2\npublish_to: none\n'
            'dependencies:\n  looseleaf_ui: ^0.1.0\n  flag: true\n',
          ),
        ),
        'attr:name punct:: plain:gallery comment:# app attr:version punct:: '
        'number:1.2 attr:publish_to punct:: plain:none attr:dependencies '
        'punct:: attr:looseleaf_ui punct:: plain:^0.1.0 attr:flag punct:: '
        'literal:true',
      );
    });

    test('lists, quotes, anchors, flow maps and markers', () {
      expect(
        _show(
          lex(
            '---\n- name: "a: b"\n  base: &b {x: 1, y: ~}\n- *b\n'
            '- url: http://x.y/#z\n',
          ),
        ),
        'punct:--- punct:- attr:name punct:: string:"a: b" attr:base punct:: '
        'variable:&b punct:{ attr:x punct:: number:1 punct:, attr:y punct:: '
        'literal:~ punct:} punct:- variable:*b punct:- attr:url punct:: '
        'plain:http://x.y/#z',
      );
    });

    test('lines never hold a newline', () {
      final lines = CodeTokenizer.lines('a:\n  - b\n', CodeLang.yaml);
      expect(lines, hasLength(3));
      for (final line in lines) {
        for (final token in line) {
          expect(token.text, isNot(contains('\n')));
        }
      }
    });
  });
}
