import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_burst.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints the pieces of [bursts] at [clock]'s time: each drawn piece
/// (`confettiPiece`) moved, turned, flipped and faded along its flight,
/// like upstream's per-piece `transform` and `opacity` keyframes.
class ConfettiPainter extends CustomPainter {
  ConfettiPainter({
    required this.bursts,
    required this.clock,
    required this.theme,
  }) : super(repaint: clock);

  final List<ConfettiBurst> bursts;
  final ValueListenable<Duration> clock;
  final LooseleafThemeData theme;

  static final Map<String, ({InkDocument document, double w, double h})>
  _pieces = {};

  static ({InkDocument document, double w, double h}) _piece(Flight flight) {
    final key = '${flight.kind.name}|${flight.color.name}|${flight.variant}';
    return _pieces.putIfAbsent(key, () {
      final piece = confettiPiece(
        flight.kind,
        flight.color.paint,
        flight.variant,
      );
      return (
        document: InkDocument.parse(piece.svg),
        w: piece.w,
        h: piece.h,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value;
    final context = InkPaintContext(theme: theme);
    final painters = <InkDocument, InkPainter>{};
    for (final burst in bursts) {
      final origin = burst.origin;
      if (origin == null) continue;
      final elapsed = now - burst.started;
      for (final flight in burst.flights) {
        final frame = ConfettiBurst.frameAt(flight, elapsed);
        if (frame == null || frame.opacity <= 0) continue;
        final piece = _piece(flight);
        final k = flight.scale * burst.scalar;
        final painter = painters.putIfAbsent(
          piece.document,
          () => InkPainter(piece.document, context),
        );
        canvas.save();
        canvas.translate(origin.dx + frame.x, origin.dy + frame.y);
        canvas.rotate(frame.rot.roundToDouble() * math.pi / 180);
        canvas.scale(1, frame.flip);
        canvas.translate(-piece.w * k / 2, -piece.h * k / 2);
        canvas.scale(k);
        painter.paintLayer(canvas, 'rest', opacity: frame.opacity);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.bursts != bursts || oldDelegate.theme != theme;
}
