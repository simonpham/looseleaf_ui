import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The letter in an [Envelope]: a [Paper] between the panels, 5 % in from
/// each side, rising about a third of the envelope's height above its top
/// edge; the front hides the rest. It is built only while the envelope is
/// open, and slides up and fades in as it opens. Its [child] is padded
/// 20 px and clipped to the sheet: keep it to a few lines.
///
/// Mirrors `EnvelopeLetter` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeLetter extends StatelessWidget {
  const EnvelopeLetter({
    super.key,
    required this.child,
    this.stock = StockName.paper,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.rules,
    this.shadow = PaperShadow.stock,
    this.seed,
  });

  /// What the letter says.
  final Widget child;

  /// The letter's paper.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the letter flat.
  final bool tilt;

  /// A fixed tilt in degrees.
  final double? tiltDegrees;

  /// The printed rules; the stock's when null.
  final RuleName? rules;

  /// The shadow.
  final PaperShadow shadow;

  /// Pins the sheet.
  final String? seed;

  /// How far the letter rises above where it rests, as a share of its own
  /// height (upstream's `-translate-y-[38%]`).
  static const double rise = 0.38;

  /// Where the slide starts below its place, as a share of its height.
  static const double slide = 0.3;

  @override
  Widget build(BuildContext context) {
    final envelope = EnvelopeScope.maybeOf(context);
    if (envelope?.open != true) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: InkMotion.of(context, InkMotion.sheet),
          curve: InkMotion.easeOut,
          builder: (context, t, child) => Transform.translate(
            offset: Offset(0, height * (-rise + slide * (1 - t))),
            child: Opacity(opacity: t, child: child),
          ),
          child: Paper(
            stock: stock,
            edge: edge,
            tilt: tilt,
            tiltDegrees: tiltDegrees,
            rules: rules,
            shadow: shadow,
            seed: seed ?? '${envelope?.seed ?? 'envelope'}|letter',
            child: ClipRect(
              child: OverflowBox(
                alignment: AlignmentDirectional.topStart,
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.d20),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: theme.colors.ink),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
