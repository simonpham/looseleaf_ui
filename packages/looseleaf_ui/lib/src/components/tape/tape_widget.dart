import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A strip of tape: masking, washi (dots, stripes, zigzag, gingham), kraft
/// or clear, with sawn, torn, straight or scissor-cut ends, laid at a small
/// seeded angle (at most 2.5 times the tilt budget, flat when calm) with a
/// thin drop shadow. Decorative.
///
/// ```dart
/// const Tape(kind: TapeKind.washiDots, length: 96)
/// ```
///
/// Mirrors upstream `src/components/ui/tape.tsx`.
class Tape extends StatefulWidget {
  const Tape({
    super.key,
    this.kind = TapeKind.masking,
    this.length = 72,
    this.height = 22,
    this.angle,
    this.ends,
    this.color,
    this.seed,
  });

  /// The tape.
  final TapeKind kind;

  /// The strip's length in px.
  final double length;

  /// The strip's width across, in px.
  final double height;

  /// The angle in degrees; seeded within ±4 when null.
  final double? angle;

  /// How the ends are cut; the kind's own when null.
  final TapeEnds? ends;

  /// A washi tape's print colour; the kind's own when null.
  final Accent? color;

  /// Pins the drawing and the angle.
  final String? seed;

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = '${inkSeed(widget.seed)}|tape';
    final tier = PaperInk.tier(theme);
    final calm = PaperInk.calm(theme);
    final degrees = widget.angle ?? tiltFor(seed, 4);
    return InkArt(
      cacheKey: [
        'tape',
        seed,
        widget.kind.id,
        widget.length,
        widget.height,
        widget.ends?.name,
        widget.color?.name,
        tier.name,
        calm,
      ].join('|'),
      draw: () => tape(
        seed,
        kind: widget.kind,
        length: widget.length,
        height: widget.height,
        ends: widget.ends,
        color: widget.color,
        tier: tier,
        calm: calm,
      ),
      drop: DropKind.tape,
      rotation: PaperInk.tilt(context, degrees, factor: 2.5),
    );
  }
}
