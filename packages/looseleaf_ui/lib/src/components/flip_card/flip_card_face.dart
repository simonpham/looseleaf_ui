import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_axis.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_scope.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which face of a [FlipCard] a [FlipCardFace] is.
enum FlipCardSide { front, back }

/// One face of a [FlipCard]: a flat, cut sheet filling the card, its words
/// centred in 24 px script. Only the face that is up is painted, focusable
/// and read; the other is inert. [FlipCardFront] and [FlipCardBack] are the
/// two you use.
///
/// Mirrors `Face` in upstream `src/components/ui/flip-card.tsx`.
class FlipCardFace extends StatelessWidget {
  const FlipCardFace({
    super.key,
    required this.side,
    required this.children,
    this.stock,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.spacing = Spacing.d4,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.d24,
      vertical: Spacing.d20,
    ),
    this.textSize = 24,
    this.seed,
  });

  final FlipCardSide side;

  /// The lines on the face, stacked and centred.
  final List<Widget> children;

  /// The paper; an index card in front and a slip behind when null.
  final StockName? stock;

  /// How the lines line up (`items-center`).
  final CrossAxisAlignment crossAxisAlignment;

  /// How text lines up (`text-center`).
  final TextAlign textAlign;

  /// The gap between lines (`gap-1`).
  final double spacing;

  /// `px-6 py-5`.
  final EdgeInsetsGeometry padding;

  /// The script size in CSS px (`text-2xl`).
  final double textSize;

  /// Pins the sheet's tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = FlipCardScope.of(context);
    final theme = LooseleafTheme.of(context);
    final front = side == FlipCardSide.front;
    final hidden = scope.flipped == front;
    final sheet = Paper(
      stock:
          stock ??
          switch (front) {
            true => StockName.indexCard,
            false => StockName.slip,
          },
      edge: const EdgeSpec(),
      tilt: false,
      seed: seed,
      padding: padding,
      child: SizedBox.expand(
        child: DefaultTextStyle.merge(
          textAlign: textAlign,
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: textSize,
            cssLineHeight: 1.25,
            color: theme.colors.ink,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: crossAxisAlignment,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      excluding: hidden,
      child: ExcludeFocus(
        excluding: hidden,
        child: IgnorePointer(
          ignoring: hidden,
          child: AnimatedBuilder(
            animation: scope.turn,
            builder: (context, child) {
              final backUp = math.cos(scope.turn.value * math.pi) < 0;
              return Visibility.maintain(
                visible: backUp != front,
                child: switch (front) {
                  true => child ?? const SizedBox.shrink(),
                  false => Transform(
                    alignment: Alignment.center,
                    transform: switch (scope.axis) {
                      FlipCardAxis.x => Matrix4.rotationX(math.pi),
                      FlipCardAxis.y => Matrix4.rotationY(math.pi),
                    },
                    child: child,
                  ),
                },
              );
            },
            child: sheet,
          ),
        ),
      ),
    );
  }
}
