import 'package:looseleaf_ink/looseleaf_ink.dart';

/// Which pad a sticky note came off.
///
/// Mirrors `StickyColor` in upstream `src/components/ui/sticky-note.tsx`.
enum StickyColor {
  yellow(StockName.stickyYellow),
  green(StockName.stickyGreen),
  orange(StockName.stickyOrange),
  pink(StockName.stickyPink),
  blue(StockName.stickyBlue);

  const StickyColor(this.stock);

  /// The paper stock of the pad.
  final StockName stock;
}
