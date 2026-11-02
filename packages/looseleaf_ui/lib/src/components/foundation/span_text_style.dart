import 'package:flutter/widgets.dart';

/// Gives [child] the text style of the span it sits in when it is (inside)
/// the child of a [WidgetSpan], so a marked word in
/// `Text.rich(style: …)` or under a styled [TextSpan] matches its sentence.
///
/// Flutter builds a [WidgetSpan]'s child with the ambient
/// [DefaultTextStyle] only; the enclosing [Text]'s `style` and its spans'
/// styles never reach it. This finds the [RichText] the child is laid out
/// in, merges the styles from its root span down to the [WidgetSpan], and
/// puts them in a [DefaultTextStyle] around [child]. Outside a
/// [WidgetSpan] it returns [child] unchanged. Every text mark wraps its
/// content in one.
class SpanTextStyle extends StatelessWidget {
  const SpanTextStyle({super.key, required this.child});

  final Widget child;

  /// The merged style of the span that [context] sits in, or null outside
  /// a [WidgetSpan].
  static TextStyle? of(BuildContext context) {
    final path = <Widget>[];
    RichText? paragraph;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is RichText) {
        paragraph = widget;
        return false;
      }
      if (widget is MultiChildRenderObjectWidget) return false;
      path.add(widget);
      return true;
    });
    final rich = paragraph;
    if (rich == null) return null;
    return _find(rich.text, null, path);
  }

  /// The ambient [DefaultTextStyle] with [of] merged on top: the style
  /// text at [context] is drawn with.
  static TextStyle resolve(BuildContext context) {
    final ambient = DefaultTextStyle.of(context).style;
    return switch (of(context)) {
      final span? => ambient.merge(span),
      null => ambient,
    };
  }

  static TextStyle? _find(
    InlineSpan span,
    TextStyle? inherited,
    List<Widget> path,
  ) {
    final style = switch ((inherited, span.style)) {
      (final base?, final own?) => base.merge(own),
      (final base, null) => base,
      (null, final own) => own,
    };
    if (span case WidgetSpan(:final child)) {
      if (!path.any((widget) => identical(widget, child))) return null;
      return style ?? const TextStyle();
    }
    if (span case TextSpan(:final children?)) {
      for (final nested in children) {
        if (_find(nested, style, path) case final found?) return found;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => switch (of(context)) {
    final style? => DefaultTextStyle.merge(style: style, child: child),
    null => child,
  };
}
