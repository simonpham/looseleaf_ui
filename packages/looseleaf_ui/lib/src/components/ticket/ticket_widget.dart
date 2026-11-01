import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/ticket/ticket_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ticket: concave corners, a bite out of both edges where the stub
/// tears off, a row of holes along the tear (cut out, so the desk shows
/// through) and a printed frame. [children] ([TicketBody], [TicketStub])
/// sit in a row at least 112 px tall, as wide as the parent allows up to
/// [maxWidth]. The stub sits at the [stub] side, [stubWidth] wide, and
/// mirrors right to left; [punched] punches a hole through the body. The
/// drawing turns a seeded hair (within 1.2°, flat when calm); the text
/// stays upright.
///
/// ```dart
/// const Ticket(
///   semanticLabel: 'Ticket 0042',
///   children: [
///     TicketBody(children: [
///       TicketTitle(Text('Admit one')),
///       TicketDescription(Text('Le Grand Jardin')),
///     ]),
///     TicketStub(children: [TicketNumber(Text('No. 0042'))]),
///   ],
/// )
/// ```
///
/// Mirrors `Ticket` in upstream `src/components/ui/ticket.tsx`.
class Ticket extends StatefulWidget {
  const Ticket({
    super.key,
    this.stock = StockName.kraft,
    this.stub = TicketStubSide.end,
    this.stubWidth = 88,
    this.punched = false,
    this.maxWidth = defaultMaxWidth,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
    this.semanticLabel,
    this.children = const [],
  });

  /// Upstream's `max-w-lg`.
  static const double defaultMaxWidth = 512;

  /// Upstream's `min-h-28`.
  static const double minHeight = 112;

  /// The largest seeded turn, in degrees.
  static const double tiltMax = 1.2;

  /// What it is printed on.
  final StockName stock;

  /// Where the tear-off stub is, or none.
  final TicketStubSide stub;

  /// The stub's width in px; the tear sits that far from the edge.
  final double stubWidth;

  /// A hole punched through the body: the ticket has been used. Say so in
  /// text as well.
  final bool punched;

  /// The largest width.
  final double maxWidth;

  /// False lays it flat.
  final bool tilt;

  /// A fixed turn in degrees, clamped to the tilt budget; seeded within
  /// 1.2° when null.
  final double? tiltDegrees;

  /// Pins the cut, the holes and the turn.
  final String? seed;

  /// Names the ticket as one group, for a page of tickets.
  final String? semanticLabel;

  /// The parts: a [TicketBody] and a [TicketStub], in reading order.
  final List<Widget> children;

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, Ticket.tiltMax),
    };
    final params = TicketParams(
      stock: widget.stock,
      stub: widget.stub,
      stubWidth: widget.stubWidth,
      punched: widget.punched,
    );
    final direction = Directionality.of(context);
    final reversed = switch (direction) {
      TextDirection.ltr => TextDirection.rtl,
      TextDirection.rtl => TextDirection.ltr,
    };
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Ticket.minHeight),
      child: IntrinsicHeight(
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colors.ink),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            textDirection: switch (widget.stub) {
              TicketStubSide.start => reversed,
              _ => direction,
            },
            children: widget.children,
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: TicketScope(
        stubWidth: widget.stubWidth,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: switch (constraints.maxWidth.isFinite) {
              true => math.min(widget.maxWidth, constraints.maxWidth),
              false => widget.maxWidth,
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Transform.rotate(
                    angle: PaperInk.tilt(context, degrees),
                    child: InkSurface(
                      source: RecipeInkSource(
                        ticketRecipe,
                        params,
                        json: params.toJson(),
                      ),
                      seed: seed,
                      still: true,
                    ),
                  ),
                ),
                row,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
