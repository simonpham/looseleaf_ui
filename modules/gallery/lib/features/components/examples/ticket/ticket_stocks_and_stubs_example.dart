import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TicketStocksAndStubsExample extends StatelessWidget {
  const TicketStocksAndStubsExample({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d16),
    child: Column(
      spacing: Spacing.d36,
      children: [
        Ticket(
          stock: StockName.stickyYellow,
          punched: true,
          seed: 'cinema',
          semanticLabel: 'Cinema ticket, used',
          children: [
            TicketBody(
              children: [
                TicketTitle(Text('Cinema')),
                TicketDescription(Text('Sat 27 Sep - 19:30')),
                TicketNumber(Text('Screen 2 - Row F - Seat 14')),
              ],
            ),
            TicketStub(children: [TicketNumber(cssSize: 18, Text('1187'))]),
          ],
        ),
        Ticket(
          stock: StockName.indexCard,
          stub: TicketStubSide.start,
          stubWidth: 80,
          seed: 'raffle',
          semanticLabel: 'Raffle ticket 311',
          children: [
            TicketBody(
              children: [
                TicketTitle(Text('Raffle')),
                TicketDescription(Text('Win a very small pencil')),
              ],
            ),
            TicketStub(children: [TicketNumber(cssSize: 20, Text('311'))]),
          ],
        ),
        Ticket(
          stock: StockName.stickyPink,
          stub: TicketStubSide.none,
          seed: 'tram',
          semanticLabel: 'One tram ride',
          children: [
            TicketBody(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TicketTitle(Text('One ride', textAlign: TextAlign.center)),
                TicketDescription(
                  Text('Good until the last tram', textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
        Ticket(
          stubWidth: 120,
          seed: 'fair',
          semanticLabel: 'Fair entry 0007',
          children: [
            TicketBody(
              children: [
                TicketTitle(Text('Admit one')),
                TicketDescription(Text('The Looseleaf Fair - Sunday')),
              ],
            ),
            TicketStub(
              children: [
                TicketNumber(
                  cssSize: 20,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TicketNumber(cssSize: 12, Text('No.')),
                      Text('0007'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
