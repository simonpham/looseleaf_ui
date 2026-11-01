import 'package:looseleaf_ink/looseleaf_ink.dart';

/// A [RibbonSize]'s label typography, from `RIBBON_SIZES[size].text` in
/// upstream `src/lib/ink/recipes/ribbon-ink.ts` (`text-sm`, `text-base`,
/// `text-xl`).
extension RibbonMetrics on RibbonSize {
  /// The CSS line height Tailwind's text class sets with [RibbonSize.font].
  double get cssLineHeight => switch (this) {
    RibbonSize.sm => 20 / 14,
    RibbonSize.regular => 1.5,
    RibbonSize.lg => 28 / 20,
  };
}
