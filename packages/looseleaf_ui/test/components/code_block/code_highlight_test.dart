import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

List<CodeToken> _tokens(Object? json) => [
  for (final pair in json as List<Object?>)
    if (pair case [final String type, final String text])
      CodeToken(CodeTokenType.values.byName(type), text),
];

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/code_highlight.json').readAsStringSync(),
          )
          as Map<String, Object?>;

  group('tokens match upstream', () {
    for (final entry in fixture['tokens'] as List<Object?>) {
      final c = entry as Map<String, Object?>;
      final name = c['name'] as String;
      final lang = CodeLang.values.byName(c['lang'] as String);
      final code = c['code'] as String;
      test('$name (${lang.name})', () {
        if (c['tokens'] case final List<Object?> tokens) {
          expect(CodeTokenizer.tokenize(code, lang), _tokens(tokens));
        }
        final lines = [
          for (final line in c['lines'] as List<Object?>) _tokens(line),
        ];
        expect(CodeTokenizer.lines(code, lang), lines);
      });
    }
  });

  test('diffs parse, apply and count like upstream', () {
    for (final entry in fixture['diffs'] as List<Object?>) {
      final c = entry as Map<String, Object?>;
      final rows = CodeDiff.parse(c['code'] as String);
      expect(rows, [
        for (final row in c['rows'] as List<Object?>)
          if (row case {'kind': final String kind, 'text': final String text})
            DiffLine(DiffKind.values.byName(kind), text),
      ]);
      expect(CodeDiff.result(rows), c['result']);
      final stats = c['stats'] as Map<String, Object?>;
      expect(CodeDiff.stats(rows), (
        added: stats['added'],
        removed: stats['removed'],
      ));
    }
  });

  test('languages resolve from names and file names like upstream', () {
    for (final pair in fixture['langs'] as List<Object?>) {
      if (pair case [final String name, final String lang]) {
        expect(CodeLang.parse(name).name, lang, reason: name);
      }
    }
    expect(CodeLang.parse(null).name, fixture['undefinedLang']);
    for (final pair in fixture['fileNames'] as List<Object?>) {
      if (pair case [final String file, final String lang]) {
        expect(CodeLang.fromFileName(file).name, lang, reason: file);
      }
    }
  });
}
