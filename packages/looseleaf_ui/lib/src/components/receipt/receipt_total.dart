import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/receipt/receipt.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A receipt's total: the [label] and the amount at the two ends, at 16 px
/// bold. [circled] loops the amount in felt tip (red, blue or ink; a
/// hairline when calm), as whoever checked it would.
///
/// Mirrors `ReceiptTotal` in upstream `src/components/ui/receipt.tsx`.
class ReceiptTotal extends StatefulWidget {
  const ReceiptTotal({
    super.key,
    required this.child,
    this.label = const Text('TOTAL'),
    this.circled,
    this.seed,
  });

  /// The amount, usually a [Text].
  final Widget child;

  /// The label.
  final Widget label;

  /// The pen circling the amount; none when null.
  final ReceiptPen? circled;

  /// Pins the hand of the loop.
  final String? seed;

  @override
  State<ReceiptTotal> createState() => _ReceiptTotalState();
}

class _ReceiptTotalState extends State<ReceiptTotal> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final amount = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFeatures: ReceiptLine.figures),
        child: widget.child,
      ),
    );
    final pen = widget.circled;
    final Widget value = switch (pen) {
      null => amount,
      final pen => InkSurface(
        source: RecipeInkSource(
          receiptCircleRecipe,
          ReceiptCircleParams(pen: pen),
          json: ReceiptCircleParams(pen: pen).toJson(),
        ),
        seed: inkSeed(widget.seed),
        still: true,
        child: amount,
      ),
    };
    return MergeSemantics(
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.type,
          cssSize: 16,
          cssLineHeight: 1.5,
          fontWeight: FontWeight.w700,
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d12,
          children: [widget.label, value],
        ),
      ),
    );
  }
}
