import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The sheet a [SketchpadCanvas] draws on.
///
/// Mirrors `PAPERS` in upstream `src/components/ui/sketchpad.tsx`.
enum SketchpadPaper {
  /// Plain paper.
  plain(StockName.paper, RuleName.none),

  /// Paper with blue rules.
  ruled(StockName.paper, RuleName.ruled),

  /// Graph paper.
  graph(StockName.graph, null),

  /// A dot grid.
  dots(StockName.dotGrid, null),

  /// Brown kraft paper.
  kraft(StockName.kraft, RuleName.none);

  const SketchpadPaper(this.stock, this.rules);

  /// The paper stock.
  final StockName stock;

  /// The printed rules; the stock's own when null.
  final RuleName? rules;
}
