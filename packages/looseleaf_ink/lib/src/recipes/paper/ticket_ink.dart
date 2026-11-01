import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Where a ticket's tear-off stub is.
///
/// Mirrors `TicketStub` in `src/lib/ink/recipes/ticket-ink.ts`, renamed
/// to leave `TicketStub` to the widget.
enum TicketStubSide { end, start, none }

/// Ticket recipe params.
///
/// Mirrors `TicketParams` in `src/lib/ink/recipes/ticket-ink.ts`.
final class TicketParams {
  /// Params.
  const TicketParams({
    required this.stock,
    required this.stub,
    required this.stubWidth,
    required this.punched,
  });

  /// The paper stock.
  final StockName stock;

  /// The stub's side.
  final TicketStubSide stub;

  /// The stub's width.
  final double stubWidth;

  /// A punched hole near the bottom of the body.
  final bool punched;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'stock': stock.id,
    'stub': stub.name,
    'stubWidth': stubWidth,
    'punched': punched,
  };
}

/// Ticket geometry: the corner radius, the stub notch radius, the
/// perforation hole radius and gap, and the printed frame's inset.
///
/// Mirrors `TICKET` in `src/lib/ink/recipes/ticket-ink.ts`.
const ({
  double corner,
  double notch,
  double hole,
  double holeGap,
  double frameInset,
})
ticketLayout = (corner: 6, notch: 8, hole: 1.2, holeGap: 6.6, frameInset: 7);

/// The outline of a [w]×[h] ticket with a notched, perforated stub line at
/// [sx] (none when outside the ticket), and the perforations plus punched
/// [holes] as circles.
///
/// Mirrors `ticketPath` in `src/lib/ink/recipes/ticket-ink.ts`.
({String d, String holesD}) ticketPath(
  double w,
  double h,
  double sx, [
  List<Pt> holes = const [],
]) {
  const c = 6;
  const nr = 8;
  final d = StringBuffer('M${num10(c.toDouble())} 0');
  final notch = sx > 0 && sx < w;
  if (notch) d.write('H${num10(sx - nr)}A$nr $nr 0 0 0 ${num10(sx + nr)} 0');
  d.write(
    'H${num10(w - c)}A$c $c 0 0 0 ${num10(w)} ${c}V${num10(h - c)}'
    'A$c $c 0 0 0 ${num10(w - c)} ${num10(h)}',
  );
  if (notch) {
    d.write('H${num10(sx + nr)}A$nr $nr 0 0 0 ${num10(sx - nr)} ${num10(h)}');
  }
  d.write(
    'H${num10(c.toDouble())}A$c $c 0 0 0 0 ${num10(h - c)}'
    'V${num10(c.toDouble())}A$c $c 0 0 0 ${num10(c.toDouble())} 0z',
  );
  final holesD = StringBuffer();
  if (notch) {
    for (var y = nr + 7.0; y < h - nr - 6; y += ticketLayout.holeGap) {
      holesD.write(circleD(sx, y, ticketLayout.hole));
    }
  }
  for (final (x, y) in holes) {
    holesD.write(circleD(x, y, 5.6));
  }
  return (d: '$d', holesD: '$holesD');
}

/// A ticket: the paper with its stub notches and perforation, printed
/// double frames, a punched hole and a lit top edge.
///
/// Mirrors `ticketRecipe` in `src/lib/ink/recipes/ticket-ink.ts`.
final Recipe<TicketParams> ticketRecipe = defineRecipe<TicketParams>(
  id: 'ticket-sheet',
  kind: 'sheet',
  layers: const [LayerName.rest],
  pad: 4,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final TicketParams(:stub, :stubWidth) = params;
    final r = ink.next('ticket');
    final rtl = ctx.dir == Dir.rtl;
    final left = (stub == TicketStubSide.start) != rtl;
    final none = stub == TicketStubSide.none;
    final sx = switch ((none, left)) {
      (true, _) => -1.0,
      (false, true) => stubWidth,
      (false, false) => w - stubWidth,
    };
    final (bodyStart, bodyEnd) = switch ((none, left)) {
      (true, _) => (0.0, w),
      (false, true) => (sx, w),
      (false, false) => (0.0, sx),
    };
    final px = switch (rtl) {
      true => bodyStart + 32,
      false => bodyEnd - 32,
    };
    final List<Pt> punch = switch (params.punched) {
      true => [(px + r.gauss(0, 2), h - 30 + r.gauss(0, 2.5))],
      false => const [],
    };
    final (:d, :holesD) = ticketPath(w, h, sx, punch);
    ink.layer(LayerName.rest, () {
      final s = StringBuffer(
        paperFill(
          ink.seed,
          d + holesD,
          stock: params.stock,
          evenodd: true,
          shadow: true,
          inset: const [0.5, 0.5, 0.5, 0.5],
        ),
      );
      final fi = ticketLayout.frameInset;
      String frame(double x0, double x1) =>
          'M${num10(x0)} ${num10(fi)}H${num10(x1)}V${num10(h - fi)}H${num10(x0)}z';
      final (b0, b1) = switch ((none, left)) {
        (true, _) => (fi, w - fi),
        (false, true) => (sx + fi + 2, w - fi),
        (false, false) => (fi, sx - fi - 2),
      };
      s
        ..write(pathTag(frame(b0, b1), stroke: tok('ink'), sw: 0.8, op: 0.34))
        ..write(
          pathTag(frame(b0 + 2, b1 - 2), stroke: tok('ink'), sw: 0.5, op: 0.2),
        );
      if (!none) {
        final (s0, s1) = switch (left) {
          true => (fi, sx - fi - 2),
          false => (sx + fi + 2, w - fi),
        };
        s
          ..write(
            pathTag(frame(s0, s1), stroke: tok('ink'), sw: 0.8, op: 0.34),
          )
          ..write(
            pathTag(
              'M${num10(sx)} ${num10(ticketLayout.notch)}'
              'V${num10(h - ticketLayout.notch)}',
              stroke: tok('ink'),
              sw: 0.6,
              op: 0.1,
            ),
          );
      }
      s.write(
        litEdge(
          'M${num10(ticketLayout.corner)} 0.6H${num10(w - ticketLayout.corner)}',
          0.7,
        ),
      );
      ink
        ..raw('$s', Material.under)
        ..grow(BBox(-2, -2, w + 2, h + 2));
    });
  },
);
