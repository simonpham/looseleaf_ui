/// A language the code block's lexer knows.
///
/// Mirrors `Lang` in upstream `src/lib/code-highlight.ts`.
enum CodeLang {
  tsx,
  ts,
  jsx,
  js,
  css,
  bash,
  json,
  diff,
  text;

  static const Map<String, CodeLang> _aliases = {
    'tsx': tsx,
    'ts': ts,
    'typescript': ts,
    'jsx': jsx,
    'js': js,
    'javascript': js,
    'mjs': js,
    'cjs': js,
    'css': css,
    'scss': css,
    'json': json,
    'jsonc': json,
    'bash': bash,
    'sh': bash,
    'shell': bash,
    'zsh': bash,
    'console': bash,
    'diff': diff,
    'patch': diff,
    'html': text,
    'text': text,
    'txt': text,
  };

  /// The language named [name] or one of its aliases (`typescript`, `sh`,
  /// `patch`, …), case-insensitive; [text] when unknown. Upstream
  /// `normaliseLang`.
  static CodeLang parse(String? name) =>
      _aliases[(name ?? '').toLowerCase()] ?? text;

  /// The language of a file from its extension; [text] without one.
  /// Upstream `langFromFileName`.
  static CodeLang fromFileName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return text;
    return parse(name.substring(dot + 1));
  }
}
