import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The shadow a sheet casts.
///
/// Mirrors `PaperProps['shadow']` in upstream `src/components/ui/paper.tsx`:
/// `stock` (the stock's own, a hairline when calm), `none`, or a named kind.
enum PaperShadow {
  stock(null),
  none(null),
  hair(SheetShadowKind.hair),
  loose(SheetShadowKind.loose),
  lift(SheetShadowKind.lift),
  slip(SheetShadowKind.slip),
  card(SheetShadowKind.card),
  pad(SheetShadowKind.pad),
  check(SheetShadowKind.check),
  paper(SheetShadowKind.paper),
  sticky(SheetShadowKind.sticky);

  const PaperShadow(this.kind);

  /// The named kind, null for [stock] and [none].
  final SheetShadowKind? kind;

  /// The kind a sheet of [stock] casts, null for none.
  SheetShadowKind? resolve(StockName stock, {required bool calm}) =>
      switch (this) {
        PaperShadow.none => null,
        PaperShadow.stock when calm => SheetShadowKind.hair,
        PaperShadow.stock => stockOf(stock).shadow,
        _ => kind,
      };
}
