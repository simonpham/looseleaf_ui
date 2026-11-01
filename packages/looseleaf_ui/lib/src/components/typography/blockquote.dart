import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/typography/typography.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A quotation in soft script beside a hand-drawn marker bar; the seed
/// picks one of three bars.
///
/// ```dart
/// const Blockquote(
///   child: Text('The best time to write it down was when it happened.'),
/// )
/// ```
///
/// Mirrors `Blockquote` in upstream `src/components/ui/typography.tsx`.
class Blockquote extends StatefulWidget {
  const Blockquote({super.key, required this.child, this.seed});

  final Widget child;

  /// Picks the bar: the same seed always draws the same one.
  final String? seed;

  @override
  State<Blockquote> createState() => _BlockquoteState();
}

class _BlockquoteState extends State<Blockquote> with InkSeed {
  /// The bar's `opacity-80`.
  static const double _barOpacity = 0.8;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final marker = theme.colors.marker;
    return Stack(
      children: [
        PositionedDirectional(
          start: 0,
          top: Spacing.d2,
          bottom: Spacing.d2,
          width: Spacing.d8,
          child: CustomPaint(
            painter: QuoteBarPainter(
              index:
                  hashSeed(inkSeed(widget.seed)) % typographyQuoteBars.length,
              color: marker.withValues(alpha: marker.a * _barOpacity),
              theme: theme,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: Spacing.d20),
          child: TypographyText(
            style: TypographyStyle.blockquote,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
