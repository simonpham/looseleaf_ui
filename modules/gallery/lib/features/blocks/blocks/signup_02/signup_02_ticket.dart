import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The desk beside the form: a kraft admission ticket, a party popper, a
/// member stamp and Stubby celebrating "your seat is saved".
///
/// Mirrors upstream `src/blocks/signup-02/components/signup-02-ticket.tsx`.
class Signup02Ticket extends StatelessWidget {
  const Signup02Ticket({super.key});

  static const Size _size = Size(368, 480);
  static const double _ticketTop = 88;
  static const double _ticketMinHeight = 144;
  static const double _stampTop = 200;
  static const double _stubbyStart = 120;
  static const double _captionWidth = 120;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 12,
      color: theme.colors.inkSoft,
    );
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              start: 0,
              top: _ticketTop,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _ticketMinHeight),
                child: Ticket(
                  tiltDegrees: -4,
                  stubWidth: 92,
                  maxWidth: 352,
                  seed: 'signup-02-ticket',
                  children: [
                    TicketBody(
                      children: [
                        const TicketTitle(Text('Admit one')),
                        const TicketDescription(Text('The Looseleaf Club')),
                        Text('Founding season - general', style: small),
                      ],
                    ),
                    TicketStub(
                      children: [
                        Text('No.', style: small),
                        const TicketNumber(Text('0001')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const PositionedDirectional(
              start: Spacing.d8,
              top: Spacing.d8,
              child: Sticker('party-popper', size: 92, rotate: -10),
            ),
            const PositionedDirectional(
              end: 0,
              top: _stampTop,
              child: Stamp(name: 'stamp-member', size: 120, tilt: -8),
            ),
            const PositionedDirectional(
              start: _stubbyStart,
              bottom: 0,
              child: Mascot(
                pose: 'celebrate',
                size: 190,
                seed: 'signup-02-stubby',
              ),
            ),
            PositionedDirectional(
              start: Spacing.d8,
              bottom: Spacing.d40,
              child: SizedBox(
                width: _captionWidth,
                child: Text(
                  'your seat is saved',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 32,
                    cssLineHeight: 0.95,
                    fontWeight: FontWeight.w700,
                    color: theme.colors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
