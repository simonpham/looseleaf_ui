import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/asterisk/asterisk_mark.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn footnote mark after a word or a price: an asterisk, a
/// star, a dagger or a double dagger, raised like a superscript.
///
/// With [onPressed] the mark is a link to the footnote (named [label], or
/// "footnote"), grown on hover. Without it the mark is decorative unless a
/// [label] names it.
///
/// ```dart
/// Asterisk(label: 'Footnote 1', onPressed: showNote, child: Text(r'$16'))
/// ```
///
/// Mirrors upstream `src/components/ui/asterisk.tsx`.
class Asterisk extends StatefulWidget {
  const Asterisk({
    super.key,
    this.child,
    this.mark = AsteriskMark.asterisk,
    this.tone = AsteriskTone.red,
    this.label,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
  });

  /// What the mark follows, usually a [Text].
  final Widget? child;

  final AsteriskMark mark;
  final AsteriskTone tone;

  /// The mark's accessible name.
  final String? label;

  /// Makes the mark a link (upstream `href`).
  final VoidCallback? onPressed;

  /// Pins the hand: the same seed always draws the same mark.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// `size-[0.8em]`.
  static const double sizeEm = 0.8;

  /// `align-[0.4em]`.
  static const double raiseEm = 0.4;

  /// `hover:[&>svg]:scale-125`.
  static const double hoverScale = 1.25;

  /// `after:-inset-1.5`.
  static const EdgeInsets hitSlop = EdgeInsets.all(Spacing.d6);

  @override
  State<Asterisk> createState() => _AsteriskState();
}

class _AsteriskState extends State<Asterisk> with InkSeed {
  static const double _handSizeAdjust = 0.88;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final text = DefaultTextStyle.of(context).style;
    final kevinSans =
        text.fontFamily?.endsWith(theme.typography.fontFamily) ?? false;
    final em =
        (text.fontSize ?? theme.typography.bodySize) /
        switch (kevinSans) {
          true => _handSizeAdjust,
          false => 1.0,
        };
    final glyph = _glyph(theme, em);
    final mark = switch (widget.onPressed) {
      null => glyph,
      final onPressed => _link(onPressed, glyph),
    };
    final child = widget.child;
    return Text.rich(
      TextSpan(
        children: [
          if (child != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: child,
            ),
          WidgetSpan(
            alignment: PlaceholderAlignment.aboveBaseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: Offset(0, -Asterisk.raiseEm * em),
              child: mark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glyph(LooseleafThemeData theme, double em) {
    final seed = inkSeed(widget.seed);
    final mark = widget.mark;
    final colors = theme.colors;
    return InkArt(
      cacheKey: 'asterisk|${mark.id}|$seed',
      draw: () => ink
          .drawSkeleton(
            mark.def,
            16,
            '$seed|${mark.id}',
            const ink.DrawOpts(tone: ink.ArtTone.ui, kind: ink.ArtKind.icon),
          )
          .result,
      size: Size.square(Asterisk.sizeEm * em),
      color: switch (widget.tone) {
        AsteriskTone.red => colors.red,
        AsteriskTone.ink => colors.ink,
        AsteriskTone.blue => colors.inkYou,
        AsteriskTone.pencil => colors.pencilText,
      },
      semanticLabel: switch (widget.onPressed) {
        null => widget.label,
        _ => null,
      },
    );
  }

  Widget _link(VoidCallback onPressed, Widget glyph) => InkInteraction(
    semantics: SemanticsProperties(
      link: true,
      label: widget.label ?? 'footnote',
    ),
    onActivate: onPressed,
    focusNode: widget.focusNode,
    autofocus: widget.autofocus,
    hitSlop: Asterisk.hitSlop,
    builder: (context, states) => AnimatedScale(
      scale: switch (states.contains(InkState.hovered)) {
        true => Asterisk.hoverScale,
        false => 1,
      },
      duration: InkMotion.of(context, InkMotion.hover),
      child: glyph,
    ),
  );
}
