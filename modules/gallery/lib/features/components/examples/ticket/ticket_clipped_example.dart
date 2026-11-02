import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TicketClippedExample extends StatelessWidget {
  const TicketClippedExample({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
    clipBehavior: Clip.none,
    children: [
      Ticket(
        stock: StockName.kraft,
        tiltDegrees: -2,
        seed: 'taped',
        semanticLabel: 'Ticket 0099',
        maxWidth: Spacing.d448,
        children: [
          TicketBody(
            children: [
              TicketTitle(Text('Admit one')),
              TicketDescription(Text('Museum of small things')),
            ],
          ),
          TicketStub(children: [TicketNumber(cssSize: 18, Text('0099'))]),
        ],
      ),
      Positioned(
        top: -Spacing.d8,
        left: -Spacing.d24,
        child: Tape(
          kind: TapeKind.washiStripes,
          length: 72,
          height: 22,
          angle: -24,
        ),
      ),
    ],
  );
}
