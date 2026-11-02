import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TicketEventTicketsExample extends StatefulWidget {
  const TicketEventTicketsExample({super.key});

  @override
  State<TicketEventTicketsExample> createState() =>
      _TicketEventTicketsExampleState();
}

class _TicketEventTicketsExampleState extends State<TicketEventTicketsExample> {
  static const _maxWidth = 576.0;

  var _tickets = const [
    (no: '0042', event: 'Book fair', when: 'Sat 27 Sep - 10:00', used: false),
    (
      no: '0043',
      event: 'Print workshop',
      when: 'Sun 28 Sep - 14:00',
      used: false,
    ),
    (
      no: '0017',
      event: 'Opening night',
      when: 'Fri 19 Sep - 19:30',
      used: true,
    ),
  ];

  void _scan(String no) => setState(
    () => _tickets = [
      for (final ticket in _tickets)
        switch (ticket.no == no) {
          true => (
            no: ticket.no,
            event: ticket.event,
            when: ticket.when,
            used: true,
          ),
          false => ticket,
        },
    ],
  );

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d32,
        children: [
          for (final ticket in _tickets)
            Ticket(
              key: ValueKey(ticket.no),
              punched: ticket.used,
              seed: ticket.no,
              semanticLabel: switch (ticket.used) {
                true => '${ticket.event}, ticket ${ticket.no}, used',
                false => '${ticket.event}, ticket ${ticket.no}',
              },
              children: [
                TicketBody(
                  children: [
                    TicketTitle(Text(ticket.event)),
                    TicketDescription(Text(ticket.when)),
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.d4),
                      child: switch (ticket.used) {
                        true => const TicketNumber(Text('Used')),
                        false => Button(
                          size: ButtonSize.sm,
                          variant: ButtonVariant.secondary,
                          onPressed: () => _scan(ticket.no),
                          child: const Text('Scan at the door'),
                        ),
                      },
                    ),
                  ],
                ),
                TicketStub(
                  children: [
                    TicketNumber(
                      cssSize: 18,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TicketNumber(cssSize: 12, Text('No.')),
                          Text(ticket.no),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
