import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_face.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The face of a [FlipCard] that turns up when it flips: a slip unless
/// [stock] says otherwise.
///
/// ```dart
/// const FlipCardBack(children: [Text('the cat')])
/// ```
///
/// Mirrors `FlipCardBack` in upstream `src/components/ui/flip-card.tsx`.
class FlipCardBack extends StatelessWidget {
  const FlipCardBack({
    super.key,
    required this.children,
    this.stock,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.spacing = Spacing.d4,
    this.textSize = 24,
    this.seed,
  });

  /// The lines on the face.
  final List<Widget> children;

  /// The paper; see [FlipCardFace.stock].
  final StockName? stock;

  /// How the lines line up; centred by default.
  final CrossAxisAlignment crossAxisAlignment;

  /// How text lines up; centred by default.
  final TextAlign textAlign;

  /// The gap between lines.
  final double spacing;

  /// The script size in CSS px.
  final double textSize;

  /// Pins the sheet's tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) => FlipCardFace(
    side: FlipCardSide.back,
    stock: stock,
    crossAxisAlignment: crossAxisAlignment,
    textAlign: textAlign,
    spacing: spacing,
    textSize: textSize,
    seed: seed,
    children: children,
  );
}
