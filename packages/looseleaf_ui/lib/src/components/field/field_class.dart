final _controlVariant = RegExp(
  r'^(?:placeholder|file|selection|autofill|read-only|disabled|enabled|focus|focus-visible|aria-invalid|user-invalid|invalid|required|optional)$',
);
final _padding = RegExp(r'^-?p[xytblrse]?-');
final _controlUtility = RegExp(r'^(?:resize|field-sizing)(?:-|$)');

(List<String>, String) _parse(String token) {
  final variants = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < token.length; i++) {
    final c = token[i];
    if (c == '[' || c == '(') {
      depth++;
      continue;
    }
    if (c == ']' || c == ')') {
      depth--;
      continue;
    }
    if (c == ':' && depth == 0) {
      variants.add(token.substring(start, i));
      start = i + 1;
    }
  }
  final utility = token
      .substring(start)
      .replaceFirst(RegExp('^!'), '')
      .replaceFirst(RegExp(r'!$'), '');
  return (variants, utility);
}

/// Splits a Tailwind class list between a field's drawn frame and its
/// native control: state variants (`focus:`, `placeholder:`,
/// `aria-invalid:`, …), padding and `resize` / `field-sizing` utilities go
/// to the control, the rest to the frame.
///
/// Flutter widgets take frame and control settings as separate props; this
/// keeps upstream's split for code that carries class lists over.
///
/// Mirrors `splitFieldClass` in upstream `src/lib/field-class.ts`.
({String frame, String control}) splitFieldClass(String? className) {
  final frame = <String>[];
  final control = <String>[];
  for (final token in className?.split(RegExp(r'\s+')) ?? const <String>[]) {
    if (token.isEmpty) continue;
    final (variants, utility) = _parse(token);
    final own = variants.any(
      (variant) => _controlVariant.hasMatch(
        variant
            .replaceFirst(RegExp(r'[-_]?\[.*$'), '')
            .replaceFirst(RegExp(r'/.*$'), ''),
      ),
    );
    final toControl =
        own || _padding.hasMatch(utility) || _controlUtility.hasMatch(utility);
    (switch (toControl) {
      true => control,
      false => frame,
    }).add(token);
  }
  return (frame: frame.join(' '), control: control.join(' '));
}
