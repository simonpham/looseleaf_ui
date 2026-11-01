import 'package:looseleaf_ink/looseleaf_ink.dart' show HighlightTone, MarkPen;

/// An [Annotate] color: a highlighter tone, a pen, or both where the name
/// is shared (`green`, `blue`, `orange`).
///
/// Mirrors upstream `Annotate`'s `color`, typed `HighlightTone | MarkPen`.
enum AnnotateColor {
  yellow(highlight: HighlightTone.yellow),
  pink(highlight: HighlightTone.pink),
  green(highlight: HighlightTone.green, pen: MarkPen.green),
  blue(highlight: HighlightTone.blue, pen: MarkPen.blue),
  orange(highlight: HighlightTone.orange, pen: MarkPen.orange),
  lilac(highlight: HighlightTone.lilac),
  teal(highlight: HighlightTone.teal),
  ink(pen: MarkPen.ink),
  red(pen: MarkPen.red),
  pencil(pen: MarkPen.pencil),
  marker(pen: MarkPen.marker);

  const AnnotateColor({this.highlight, this.pen});

  /// The highlighter tone of this name, when there is one.
  final HighlightTone? highlight;

  /// The pen of this name, when there is one.
  final MarkPen? pen;
}
