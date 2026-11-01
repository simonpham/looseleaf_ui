import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_face.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The face of a [FlipCard] that is up at first: an index card unless
/// [stock] says otherwise.
///
/// ```dart
/// const FlipCardFront(children: [Text('le chat')])
/// ```
///
/// Mirrors `FlipCardFront` in upstream `src/components/ui/flip-card.tsx`.
class FlipCardFront extends StatelessWidget {
  const FlipCardFront({
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
    side: FlipCardSide.front,
    stock: stock,
    crossAxisAlignment: crossAxisAlignment,
    textAlign: textAlign,
    spacing: spacing,
    textSize: textSize,
    seed: seed,
    children: children,
  );
}
