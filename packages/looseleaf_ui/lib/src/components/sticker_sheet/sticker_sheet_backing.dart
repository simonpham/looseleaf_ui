import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The backing paper a [StickerSheet] is printed on.
///
/// Mirrors `BACKINGS` in upstream `src/components/ui/sticker-sheet.tsx`.
enum StickerSheetBacking {
  /// Glossy release paper: a slip tinted 13% sky, with a sheen.
  glassine(StockName.slip),

  /// Brown kraft.
  kraft(StockName.kraft),

  /// Plain paper.
  paper(StockName.paper);

  const StickerSheetBacking(this.stock);

  /// The paper stock under it.
  final StockName stock;
}
