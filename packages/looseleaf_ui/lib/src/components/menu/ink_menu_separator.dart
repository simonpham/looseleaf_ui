import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';

/// A pencil rule between groups of rows: the hand-drawn [Separator], 6 px
/// above and below (4 calm).
///
/// Mirrors `MENU_SEPARATOR` in upstream `src/lib/menu-styles.ts`.
class InkMenuSeparator extends StatelessWidget {
  const InkMenuSeparator({
    super.key,
    this.variant = SeparatorVariant.pencil,
    this.seed,
  });

  /// How the rule is drawn.
  final SeparatorVariant variant;

  /// Pins the drawing.
  final String? seed;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Padding(
      padding: EdgeInsets.symmetric(
        vertical: InkMenuMetrics.separatorMargin.of(context),
      ),
      child: Separator(variant: variant, seed: seed),
    ),
  );
}
