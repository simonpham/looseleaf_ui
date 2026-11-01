import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A chart ready to lay out: one of the `*Spec` classes.
///
/// Mirrors `ChartSpec` in `src/lib/ink/charts/chart-layout.ts`.
abstract base class ChartSpec {
  /// A spec.
  const ChartSpec();

  /// Lays this chart out in [box]; [calm] uses the quieter hand font.
  ChartLayoutBase layout(Box box, [bool calm = false]);
}
