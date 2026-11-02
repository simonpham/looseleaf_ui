import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The part of a [TearOff] that stays: a flat sheet perforated on the
/// stub's side, torn there once the stub is off.
///
/// Mirrors `TearOffBody` in upstream `src/components/ui/tear-off.tsx`.
class TearOffBody extends StatelessWidget {
  const TearOffBody({
    super.key,
    required this.child,
    this.stock = StockName.paper,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(Spacing.d16),
    this.seed,
  });

  /// What is printed on the ticket.
  final Widget child;

  final StockName stock;

  /// A fixed width, padding included (upstream `w-64`).
  final double? width;

  /// A fixed height, padding included.
  final double? height;

  /// `p-4`.
  final EdgeInsetsGeometry padding;

  /// Pins the sheet's edges and tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = TearOffScope.of(context);
    final side = scope.sides(Directionality.of(context)).body;
    return SizedBox(
      width: width,
      height: height,
      child: Paper(
        stock: stock,
        edge: scope.edge(side),
        tilt: false,
        padding: padding,
        seed: seed,
        child: child,
      ),
    );
  }
}
