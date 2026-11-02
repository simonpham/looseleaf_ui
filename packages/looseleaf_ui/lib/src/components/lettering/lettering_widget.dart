import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/handwritten/handwritten.dart';
import 'package:looseleaf_ui/src/components/lettering/lettering_fit.dart';
import 'package:looseleaf_ui/src/components/lettering/lettering_size.dart';
import 'package:looseleaf_ui/src/components/lettering/lettering_tone.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Big hand-lettered display text, printed riso style: the ink letters
/// with a misregistered second pass in [tone] peeking out behind them, a
/// third pass in [duotone] when given.
///
/// ```dart
/// Lettering('Field notes', size: .xl, tone: .teal)
/// ```
///
/// When a word is wider than the space, the whole lettering is set smaller
/// until it fits, never broken mid-word.
///
/// Mirrors upstream `src/components/ui/lettering.tsx`.
class Lettering extends StatelessWidget {
  const Lettering(
    this.text, {
    super.key,
    this.size = LetteringSize.lg,
    this.tone = LetteringTone.marker,
    this.duotone,
    this.wobble = 0,
    this.seed,
    this.header = true,
    this.textAlign,
  });

  final String text;
  final LetteringSize size;

  /// The second pass's ink.
  final LetteringTone tone;

  /// A third pass, offset the other way.
  final LetteringTone? duotone;

  /// Writes each word a hair off the baseline ([Handwritten] strength);
  /// 0 sets it straight.
  final double wobble;

  /// Pins the [wobble].
  final String? seed;

  /// Reads as a heading (upstream renders an `h2`); false for running text.
  final bool header;

  final TextAlign? textAlign;

  /// `leading-[0.95]`.
  static const double _lineHeight = 0.95;

  /// `tracking-tight`, in em.
  static const double _tracking = -0.025;

  static final RegExp _words = RegExp(r'\S+');

  TextStyle _style(LooseleafThemeData theme, double em) {
    final misregister = switch (theme.density) {
      LooseleafDensity.calm => 0.0,
      _ => 1.0,
    };
    final second = duotone;
    return theme.typography
        .face(
          KevinSansFace.script,
          cssSize: em,
          cssLineHeight: _lineHeight,
          fontWeight: FontWeight.w700,
          color: theme.colors.ink,
        )
        .copyWith(
          letterSpacing: _tracking * em,
          shadows: [
            if (misregister > 0 && second != null)
              Shadow(
                offset: Offset(-0.035 * em, 0.07 * em),
                color: second.of(theme.colors),
              ),
            if (misregister > 0)
              Shadow(
                offset: Offset(0.055 * em, 0.045 * em),
                color: tone.of(theme.colors),
              ),
          ],
        );
  }

  double _widest(BuildContext context, TextStyle style) {
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    var widest = 0.0;
    for (final word in _words.allMatches(text)) {
      painter
        ..text = TextSpan(text: word.group(0), style: style)
        ..layout();
      widest = math.max(widest, painter.width);
    }
    painter.dispose();
    return widest;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
    final style = _style(theme, size.at(width));
    return Semantics(
      header: header,
      child: LetteringFit(
        widest: _widest(context, style),
        child: switch (wobble > 0) {
          true => Handwritten(
            text,
            style: style,
            strength: wobble,
            seed: seed,
            textAlign: textAlign,
          ),
          false => Text(text, style: style, textAlign: textAlign),
        },
      ),
    );
  }
}
