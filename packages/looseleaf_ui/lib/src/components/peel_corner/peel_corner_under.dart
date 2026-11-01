import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet under a [PeelCornerPage], kraft by default, its content in
/// the peeling corner. It is inert and hidden from screen readers until the
/// corner is open, then ordinary content (a code, a working button).
///
/// Mirrors `PeelCornerUnder` in upstream `src/components/ui/peel-corner.tsx`.
class PeelCornerUnder extends StatelessWidget {
  const PeelCornerUnder({
    super.key,
    required this.child,
    this.stock = StockName.kraft,
    this.alignment,
    this.padding = const EdgeInsets.all(Spacing.d12),
    this.seed,
  });

  /// What waits underneath.
  final Widget child;

  final StockName stock;

  /// Where [child] sits; the peeling corner when null.
  final AlignmentGeometry? alignment;

  /// `p-3`.
  final EdgeInsetsGeometry padding;

  /// Pins the sheet's tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = PeelCornerScope.of(context);
    final closed = !scope.open;
    return ExcludeSemantics(
      excluding: closed,
      child: ExcludeFocus(
        excluding: closed,
        child: IgnorePointer(
          ignoring: closed,
          child: Paper(
            stock: stock,
            tilt: false,
            padding: padding,
            seed: seed,
            child: SizedBox.expand(
              child: Align(
                alignment:
                    alignment ??
                    switch (scope.corner) {
                      PeelCornerSide.bottomRight =>
                        AlignmentDirectional.bottomEnd,
                      PeelCornerSide.bottomLeft =>
                        AlignmentDirectional.bottomStart,
                    },
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
