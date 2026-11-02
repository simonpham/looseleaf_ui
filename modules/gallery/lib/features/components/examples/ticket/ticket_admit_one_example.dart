import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TicketAdmitOneExample extends StatelessWidget {
  const TicketAdmitOneExample({super.key});

  @override
  Widget build(BuildContext context) => const Ticket(
    seed: 'admit',
    semanticLabel: 'Ticket number 0042',
    maxWidth: Spacing.d448,
    children: [
      TicketBody(
        children: [
          TicketTitle(Text('Admit one')),
          TicketDescription(Text('Le Grand Jardin')),
          TicketNumber(Text('No. 0042')),
        ],
      ),
      TicketStub(
        children: [
          TicketNumber(
            cssSize: 18,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TicketNumber(cssSize: 12, Text('No.')),
                Text('0042'),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
