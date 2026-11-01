import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';

/// The sheet options of a [BubbleShape.note] or [BubbleShape.sticky]
/// bubble, upstream's `paper: Partial<PaperProps>`.
class BubblePaper {
  const BubblePaper({
    this.tiltDegrees,
    this.tilt = true,
    this.fastener,
    this.tape,
    this.edge,
    this.curl = true,
  });

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// False lays the sheet flat.
  final bool tilt;

  /// A clip, pin, staple or binder clip.
  final FastenerKind? fastener;

  /// Tape strips across the corners or the top.
  final PaperTape? tape;

  /// The edge of each side; the stock's when null.
  final EdgeSpec? edge;

  /// The curled bottom corner, on by default.
  final bool curl;
}
