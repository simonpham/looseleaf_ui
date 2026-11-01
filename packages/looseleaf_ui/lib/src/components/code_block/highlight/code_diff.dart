/// What a unified diff line does.
///
/// Mirrors `DiffKind` in upstream `src/lib/code-highlight.ts`.
enum DiffKind { add, del, ctx, meta }

/// A line of a unified diff, without its `+`, `-` or space.
///
/// Mirrors `DiffLine` in upstream `src/lib/code-highlight.ts`.
class DiffLine {
  const DiffLine(this.kind, this.text);

  final DiffKind kind;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is DiffLine && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);

  @override
  String toString() => '${kind.name}:$text';
}

/// Unified diffs: parsing, the resulting text and the counts.
///
/// Mirrors `parseDiff`, `diffResult` and `diffStats` in upstream
/// `src/lib/code-highlight.ts`.
abstract final class CodeDiff {
  static final RegExp _meta = RegExp(
    r'^(?:diff --git |index [\da-f]+\.\.|--- (?:a/|/dev/null)|\+\+\+ (?:b/|/dev/null)|@@ |\\ No newline at end of file)',
  );

  /// The lines of [code]: git's headers, hunk marks and notes are meta,
  /// `+` adds, `-` removes, the rest is context. A trailing newline adds
  /// no line.
  static List<DiffLine> parse(String code) {
    final lines = code.split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
    return [for (final line in lines) _line(line)];
  }

  static DiffLine _line(String line) {
    if (_meta.hasMatch(line)) return DiffLine(DiffKind.meta, line);
    if (line.startsWith('+')) return DiffLine(DiffKind.add, line.substring(1));
    if (line.startsWith('-')) return DiffLine(DiffKind.del, line.substring(1));
    if (line.startsWith(' ')) return DiffLine(DiffKind.ctx, line.substring(1));
    return DiffLine(DiffKind.ctx, line);
  }

  /// The code after the change: context and added lines.
  static String result(List<DiffLine> lines) => [
    for (final line in lines)
      if (line.kind == DiffKind.add || line.kind == DiffKind.ctx) line.text,
  ].join('\n');

  /// How many lines were added and removed.
  static ({int added, int removed}) stats(List<DiffLine> lines) => (
    added: lines.where((line) => line.kind == DiffKind.add).length,
    removed: lines.where((line) => line.kind == DiffKind.del).length,
  );
}
