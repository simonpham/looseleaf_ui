import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        CircledShape,
        HighlightTone,
        MarkPen,
        MarkWeight,
        StrikeKind,
        UnderlineMarkKind;
import 'package:looseleaf_ui/src/components/annotate/annotate.dart';
import 'package:looseleaf_ui/src/components/circled/circled.dart';
import 'package:looseleaf_ui/src/components/highlight/highlight.dart';
import 'package:looseleaf_ui/src/components/scribble/scribble.dart';
import 'package:looseleaf_ui/src/components/strike/strike.dart';
import 'package:looseleaf_ui/src/components/underline/underline.dart';

/// One mark for every kind of annotation, picked by [type]: an underline,
/// a box, a circle, a highlight, a strike-through, a cross, brackets or a
/// scribble. The rough-notation style API over [Underline], [Circled],
/// [Highlight], [Strike] and [Scribble].
///
/// [color] is used where it fits the mark: highlighter tones for
/// `highlight`, pens for the rest; otherwise the mark's default shows.
///
/// ```dart
/// Annotate(
///   type: .circle,
///   color: .red,
///   animate: true,
///   child: Text('margins'),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/annotate.tsx`.
class Annotate extends StatelessWidget {
  const Annotate({
    super.key,
    required this.type,
    required this.child,
    this.color,
    this.weight,
    this.kind,
    this.show = true,
    this.animate = false,
    this.delay = Duration.zero,
    this.seed,
  });

  final AnnotateType type;

  /// The annotated text, usually a [Text].
  final Widget child;

  final AnnotateColor? color;

  /// The stroke weight; for `highlight`, `fine` is light and `brush` heavy.
  final MarkWeight? weight;

  /// The underline's stroke, for `underline`.
  final UnderlineMarkKind? kind;

  /// Show or hide the mark; turning it on with [animate] replays it.
  final bool show;

  /// Hold the mark back and draw it on once shown.
  final bool animate;

  /// The wait before the mark draws on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final pen = color?.pen;
    final markWeight = weight ?? MarkWeight.regular;
    return switch (type) {
      AnnotateType.highlight => Highlight(
        tone: color?.highlight ?? HighlightTone.yellow,
        weight: switch (weight) {
          MarkWeight.fine => HighlightWeight.light,
          MarkWeight.brush => HighlightWeight.heavy,
          _ => HighlightWeight.regular,
        },
        show: show,
        animate: animate,
        delay: delay,
        seed: seed,
        child: child,
      ),
      AnnotateType.underline => Underline(
        kind: kind ?? UnderlineMarkKind.single,
        tone: pen ?? MarkPen.ink,
        weight: markWeight,
        show: show,
        animate: animate,
        delay: delay,
        seed: seed,
        child: child,
      ),
      AnnotateType.circle => _circled(CircledShape.circle, pen, markWeight),
      AnnotateType.box => _circled(CircledShape.box, pen, markWeight),
      AnnotateType.brackets => _circled(
        CircledShape.brackets,
        pen,
        markWeight,
      ),
      AnnotateType.strikeThrough => _strike(StrikeKind.single, pen, markWeight),
      AnnotateType.crossedOff => _strike(StrikeKind.cross, pen, markWeight),
      AnnotateType.scribble => Scribble(
        tone: pen ?? MarkPen.ink,
        weight: markWeight,
        show: show,
        animate: animate,
        delay: delay,
        seed: seed,
        child: child,
      ),
    };
  }

  Widget _circled(CircledShape shape, MarkPen? pen, MarkWeight weight) =>
      Circled(
        shape: shape,
        tone: pen ?? MarkPen.ink,
        weight: weight,
        show: show,
        animate: animate,
        delay: delay,
        seed: seed,
        child: child,
      );

  Widget _strike(StrikeKind kind, MarkPen? pen, MarkWeight weight) => Strike(
    kind: kind,
    tone: pen ?? MarkPen.red,
    weight: weight,
    show: show,
    animate: animate,
    delay: delay,
    seed: seed,
    child: child,
  );
}
