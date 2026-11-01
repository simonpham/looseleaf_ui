import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/handwritten/handwritten_jitter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Text that looks written, not typeset: every word sits a hair off the
/// baseline and a touch lighter, by a seeded amount.
///
/// The words stay one run of text that wraps and reads as ordinary text.
/// In [Handwritten.rich], spans with a recognizer (links) and widget spans
/// are left exactly as given. Calm density and reduced motion turn the
/// effect off; compact density writes it lighter.
///
/// ```dart
/// Handwritten('ask sam about the pond, and bring the big umbrella!')
/// ```
///
/// Mirrors upstream `src/components/ui/handwritten.tsx`.
class Handwritten extends StatefulWidget {
  /// Writes [text] by hand.
  Handwritten(
    String text, {
    super.key,
    this.style,
    this.strength = 1,
    this.seed,
    this.textAlign,
  }) : span = TextSpan(text: text);

  /// Writes the text of [span] by hand.
  const Handwritten.rich(
    this.span, {
    super.key,
    this.style,
    this.strength = 1,
    this.seed,
    this.textAlign,
  });

  final InlineSpan span;

  /// Merged over the ambient text style.
  final TextStyle? style;

  /// 0 is plain text, 1 the default hand, 2 a hurried one.
  final double strength;

  /// Pins the hand: the same seed always writes the same line.
  final String? seed;

  final TextAlign? textAlign;

  @override
  State<Handwritten> createState() => _HandwrittenState();
}

class _HandwrittenState extends State<Handwritten> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final density = switch (theme.density) {
      LooseleafDensity.compact => 0.7,
      _ => 1.0,
    };
    final k = math.max(0.0, widget.strength) * density;
    final still =
        theme.density == LooseleafDensity.calm || InkMotion.reducedIn(context);
    if (k <= 0 || still) {
      return Text.rich(
        widget.span,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final walk = _Walk('hw|${inkSeed(widget.seed)}', k, theme.colors.ink);
    return Text.rich(
      walk.span(widget.span, base),
      style: widget.style,
      textAlign: widget.textAlign,
      semanticsLabel: widget.span.toPlainText(includeSemanticsLabels: false),
    );
  }
}

class _Walk {
  _Walk(this.seed, this.k, this.ink);

  final String seed;
  final double k;
  final Color ink;
  int _index = 0;

  static final RegExp _parts = RegExp(r'\s+|\S+');
  static final RegExp _space = RegExp(r'^\s+$');

  InlineSpan span(InlineSpan span, TextStyle inherited) {
    if (span is! TextSpan || span.recognizer != null) return span;
    final style = inherited.merge(span.style);
    final text = span.text;
    return TextSpan(
      style: span.style,
      children: [
        if (text != null)
          for (final part in _parts.allMatches(text))
            _word(part.group(0) ?? '', style),
        for (final child in span.children ?? const <InlineSpan>[])
          this.span(child, style),
      ],
    );
  }

  InlineSpan _word(String word, TextStyle style) {
    if (_space.hasMatch(word)) return TextSpan(text: word);
    final jitter = HandwrittenJitter.of(seed, _index++, k);
    final color = style.color ?? ink;
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Transform.translate(
        offset: Offset(0, jitter.dy),
        child: Text(
          word,
          style: style.copyWith(
            color: color.withValues(alpha: color.a * jitter.opacity),
          ),
        ),
      ),
    );
  }
}
