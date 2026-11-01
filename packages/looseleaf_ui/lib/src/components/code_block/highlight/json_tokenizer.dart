import 'package:looseleaf_ui/src/components/code_block/highlight/code_scan.dart';
import 'package:looseleaf_ui/src/components/code_block/highlight/code_token.dart';

/// The lexer for JSON (and JSONC comments): keys, strings, numbers and
/// literals.
///
/// Mirrors `tokenizeJson` in upstream `src/lib/code-highlight.ts`.
List<CodeToken> tokenizeJson(String src) {
  final out = CodeTokenSink();
  final number = RegExp(r'^-?\d[\d.eE+-]*');
  final literal = RegExp(r'^(?:true|false|null)\b');
  final key = RegExp(r'^\s*:');
  var i = 0;
  while (i < src.length) {
    final rest = CodeScan.slice(src, i, 200);
    if (CodeScan.match(CodeScan.whitespace, rest) case final space?) {
      out.push(CodeTokenType.plain, space);
      i += space.length;
      continue;
    }
    if (rest.startsWith('//') || rest.startsWith('/*')) {
      final block = rest.startsWith('/*');
      final found = switch (block) {
        true => src.indexOf('*/', i + 2),
        false => src.indexOf('\n', i),
      };
      final end = switch ((found < 0, block)) {
        (true, _) => src.length,
        (false, true) => found + 2,
        (false, false) => found,
      };
      out.push(CodeTokenType.comment, src.substring(i, end));
      i = end;
      continue;
    }
    if (rest[0] == '"') {
      final end = CodeScan.stringEnd(src, i, '"');
      final isKey = key.hasMatch(CodeScan.slice(src, end, 40));
      out.push(
        switch (isKey) {
          true => CodeTokenType.attr,
          false => CodeTokenType.string,
        },
        src.substring(i, end),
      );
      i = end;
      continue;
    }
    if (CodeScan.match(number, rest) case final digits?) {
      out.push(CodeTokenType.number, digits);
      i += digits.length;
      continue;
    }
    if (CodeScan.match(literal, rest) case final word?) {
      out.push(CodeTokenType.literal, word);
      i += word.length;
      continue;
    }
    out.push(CodeTokenType.punct, rest[0]);
    i++;
  }
  return out.tokens;
}
