import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/index_card/index_card.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A 3 × 5 card of cream stock with a red header rule and blue lines every
/// 30 px. [children] ([IndexCardHeader], [IndexCardContent],
/// [IndexCardFooter]) lay out on the printed rules: body text is 17 px on a
/// 30 px line. The card is as wide as it may up to [maxWidth] and at least
/// [minHeight] tall (under the padding, upstream's `min-h-0`, the content
/// sets the height); its foot stays on the grid at 104 + 30n px. [padding]
/// replaces the 20 px sides and 25 px foot. A direct [IndexCardContent]
/// child fills the space left, pushing an [IndexCardFooter] to the foot.
///
/// [hole] punches the rod hole at the foot, [flag] sticks a translucent
/// plastic flag over the end edge (mirrored right to left), [stack] shows up
/// to three cards behind it. The card turns under a quarter of a degree.
///
/// ```dart
/// const IndexCard(
///   hole: true,
///   flag: Accent.tomato,
///   stack: 2,
///   children: [
///     IndexCardHeader(children: [IndexCardTitle(Text('Sources'))]),
///     IndexCardContent(children: [Text('sketchbook, dip pen, ink')]),
///   ],
/// )
/// ```
///
/// Mirrors `IndexCard` in upstream `src/components/ui/index-card.tsx`.
class IndexCard extends StatefulWidget {
  const IndexCard({
    super.key,
    this.hole = false,
    this.flag,
    this.stack = 0,
    this.maxWidth = defaultMaxWidth,
    this.minHeight = defaultMinHeight,
    this.padding,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.children = const [],
  }) : assert(stack >= 0 && stack <= 3, 'stack is 0 to 3');

  /// Upstream's `max-w-md`.
  static const double defaultMaxWidth = 448;

  /// Upstream's `min-h-56`.
  static const double defaultMinHeight = 224;

  /// The rod hole at the bottom centre; the desk shows through.
  final bool hole;

  /// A plastic flag over the end edge; none when null.
  final Accent? flag;

  /// Cards visible behind this one, 0 to 3.
  final int stack;

  /// The largest width.
  final double maxWidth;

  /// The least height; content past it grows the card.
  final double minHeight;

  /// The space around the parts; upstream's `px-5 pb-[25px]` when null.
  final EdgeInsetsGeometry? padding;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the card flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 0.225° when null.
  final double? tiltDegrees;

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

  /// Pins the card, its decor and the tilt.
  final String? seed;

  /// The parts.
  final List<Widget> children;

  @override
  State<IndexCard> createState() => _IndexCardState();
}

class _IndexCardState extends State<IndexCard> with InkSeed {
  static const double _tiltMax = 0.5 * 0.45;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    Spacing.d20,
    0,
    Spacing.d20,
    Spacing.d24 + Spacing.d1,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final decorated = widget.hole || widget.flag != null || widget.stack > 0;
    final padding =
        widget.padding?.resolve(Directionality.of(context)) ?? _padding;
    final params = IndexCardParams(
      hole: widget.hole,
      flag: widget.flag,
      stack: widget.stack,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(widget.maxWidth, constraints.maxWidth);
        return SizedBox(
          width: width,
          child: Paper(
            stock: StockName.indexCard,
            rules: RuleName.indexCard,
            mirrorRules: theme.textDirection == TextDirection.rtl,
            edge: widget.edge,
            tilt: widget.tilt,
            tiltDegrees: degrees,
            tape: widget.tape,
            tapeKind: widget.tapeKind,
            fastener: widget.fastener,
            fastenerTone: widget.fastenerTone,
            shadow: widget.shadow,
            seed: seed,
            padding: padding,
            decor: switch (decorated) {
              false => null,
              true => Transform.rotate(
                angle: PaperInk.tilt(context, degrees),
                child: InkSurface(
                  source: RecipeInkSource(
                    indexCardRecipe,
                    params,
                    json: params.toJson(),
                  ),
                  seed: '$seed|decor',
                  still: true,
                ),
              ),
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: math.max(0.0, width - padding.horizontal),
                minHeight: math.max(0.0, widget.minHeight - padding.vertical),
              ),
              child: IntrinsicHeight(
                child: DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 17,
                    cssLineHeight: 30 / 17,
                    color: theme.colors.ink,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final child in widget.children)
                        switch (child) {
                          IndexCardContent() => Expanded(child: child),
                          _ => child,
                        },
                    ],
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
