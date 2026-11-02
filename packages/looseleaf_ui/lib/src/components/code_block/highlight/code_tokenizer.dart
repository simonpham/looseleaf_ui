import 'package:looseleaf_ui/src/components/code_block/highlight/bash_tokenizer.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_lang.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/css_tokenizer.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/dart_tokenizer.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/js_tokenizer.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/json_tokenizer.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/yaml_tokenizer.dart';

/// The code block's small lexer: tsx, ts, jsx, js, css, json, bash, dart
/// and yaml;
/// anything else is plain text.
///
/// Mirrors `tokenize` and `tokenizeLines` in upstream
/// `src/lib/code-highlight.ts`.
abstract final class CodeTokenizer {
  /// The tokens of [code] in [lang].
  static List<CodeToken> tokenize(String code, CodeLang lang) => switch (lang) {
    CodeLang.tsx || CodeLang.jsx => JsTokenizer(code, jsx: true).run(),
    CodeLang.ts || CodeLang.js => JsTokenizer(code, jsx: false).run(),
    CodeLang.css => CssTokenizer(code).run(),
    CodeLang.json => tokenizeJson(code),
    CodeLang.bash => BashTokenizer(code).run(),
    CodeLang.dart => DartTokenizer(code).run(),
    CodeLang.yaml => YamlTokenizer(code).run(),
    CodeLang.diff || CodeLang.text => [
      if (code.isNotEmpty) CodeToken(CodeTokenType.plain, code),
    ],
  };

  /// The tokens of [code] split into lines; tokens never hold a newline.
  static List<List<CodeToken>> lines(String code, CodeLang lang) {
    final lines = <List<CodeToken>>[[]];
    for (final token in tokenize(code, lang)) {
      for (final (k, part) in token.text.split('\n').indexed) {
        if (k > 0) lines.add([]);
        if (part.isNotEmpty) lines.last.add(CodeToken(token.type, part));
      }
    }
    return lines;
  }
}
