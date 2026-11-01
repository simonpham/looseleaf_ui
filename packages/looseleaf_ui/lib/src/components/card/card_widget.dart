import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A card: a [Paper] of card stock holding a column of parts
/// ([CardHeader], [CardContent], [CardFooter]) 24 px apart, with 24 px above
/// and below. Every [Paper] look is available: another stock, torn edges,
/// tape, a fastener, rules, the shadow and the tilt.
///
/// ```dart
/// Card(
///   children: [
///     CardHeader(children: [CardTitle(Text('Notifications'))]),
///     CardContent(child: Text('Choose what lands in your inbox.')),
///   ],
/// )
/// ```
///
/// Mirrors `Card` in upstream `src/components/ui/card.tsx`.
class Card extends StatelessWidget {
  const Card({
    super.key,
    this.stock = StockName.card,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.rules = RuleName.none,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.curl = false,
    this.seed,
    this.gap = Spacing.d24,
    this.padding = const EdgeInsets.symmetric(vertical: Spacing.d24),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    required this.children,
  });

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the card flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// The printed rules.
  final RuleName rules;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A fastener; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// A curled bottom-right corner.
  final bool curl;

  /// Pins the sheet's drawing and tilt.
  final String? seed;

  /// The space between parts (`gap-6`).
  final double gap;

  /// The padding around the parts (`py-6`).
  final EdgeInsetsGeometry padding;

  /// How parts line up across the card.
  final CrossAxisAlignment crossAxisAlignment;

  /// The parts.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Paper(
      stock: stock,
      edge: edge,
      tilt: tilt,
      tiltDegrees: tiltDegrees,
      rules: rules,
      tape: tape,
      tapeKind: tapeKind,
      fastener: fastener,
      fastenerTone: fastenerTone,
      shadow: shadow,
      curl: curl,
      seed: seed,
      padding: padding,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.colors.ink),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          spacing: gap,
          children: children,
        ),
      ),
    );
  }
}
