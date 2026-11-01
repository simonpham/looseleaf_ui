import 'package:looseleaf_ui/src/components/code_block/highlight/highlight.dart';

/// One line of a code block: its tokens, its diff role (null for plain
/// code) and its number (null for removed and meta lines).
class CodeBlockLine {
  const CodeBlockLine(this.tokens, {this.kind, this.number});

  final List<CodeToken> tokens;
  final DiffKind? kind;
  final int? number;

  /// The line's text.
  String get text => tokens.map((token) => token.text).join();
}

/// What a code block shows and copies.
///
/// Mirrors `buildModel` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockModel {
  const CodeBlockModel._({
    required this.language,
    required this.diff,
    required this.lines,
    required this.text,
    required this.stats,
  });

  /// [code] in [language], read as a unified diff when [diff]; the first
  /// line is numbered [startLine].
  factory CodeBlockModel.build(
    String code,
    CodeLang language, {
    required bool diff,
    int startLine = 1,
  }) {
    if (diff) return _diff(code, language, startLine);
    final text = switch (code.endsWith('\n')) {
      true => code.substring(0, code.length - 1),
      false => code,
    };
    return CodeBlockModel._(
      language: language,
      diff: false,
      lines: [
        for (final (i, tokens) in CodeTokenizer.lines(text, language).indexed)
          CodeBlockLine(tokens, number: startLine + i),
      ],
      text: text,
      stats: null,
    );
  }

  static CodeBlockModel _diff(String code, CodeLang language, int startLine) {
    final rows = CodeDiff.parse(code);
    final tokens = CodeTokenizer.lines(
      rows.map((row) => row.text).join('\n'),
      switch (language) {
        CodeLang.diff => CodeLang.text,
        _ => language,
      },
    );
    var next = startLine;
    final lines = [
      for (final (i, row) in rows.indexed)
        CodeBlockLine(
          tokens.elementAtOrNull(i) ?? const [],
          kind: row.kind,
          number: switch (row.kind) {
            DiffKind.del || DiffKind.meta => null,
            _ => next++,
          },
        ),
    ];
    return CodeBlockModel._(
      language: language,
      diff: true,
      lines: lines,
      text: CodeDiff.result(rows),
      stats: CodeDiff.stats(rows),
    );
  }

  final CodeLang language;
  final bool diff;
  final List<CodeBlockLine> lines;

  /// What copy puts on the clipboard: the code, or a diff's result.
  final String text;

  /// A diff's added and removed counts; null for plain code.
  final ({int added, int removed})? stats;
}
