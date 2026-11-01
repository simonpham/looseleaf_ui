import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/handwritten/handwritten.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
    final em = size.at(width);
    final misregister = switch (theme.density) {
      LooseleafDensity.calm => 0.0,
      _ => 1.0,
    };
    final second = duotone;
    final style = theme.typography
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
    final Widget body = switch (wobble > 0) {
      true => Handwritten(
        text,
        style: style,
        strength: wobble,
        seed: seed,
        textAlign: textAlign,
      ),
      false => Text(text, style: style, textAlign: textAlign),
    };
    return Semantics(header: header, child: body);
  }
}
