import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';

/// The sheet of paper a [Calendar] sits on, upstream's `sheet` prop: the
/// [Paper] props it passes through. `const CalendarSheet()` is upstream's
/// `sheet={true}`, a card.
class CalendarSheet {
  const CalendarSheet({
    this.stock = StockName.card,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
  });

  final StockName stock;
  final EdgeSpec? edge;

  /// False lays the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  final PaperTape? tape;
  final TapeKind tapeKind;
  final FastenerKind? fastener;
  final Accent? fastenerTone;
  final PaperShadow shadow;

  /// Pins the sheet's hand; the calendar's seed when null.
  final String? seed;
}
