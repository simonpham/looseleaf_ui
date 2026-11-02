import 'package:gallery/features/components/examples/ticket/ticket.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/ticket/`.
const ticketExamples = <GalleryExample>[
  GalleryExample(
    title: 'Admit one',
    description:
        'Concave corners, a bite out of both edges where the stub tears off, and a row of holes along the tear. The whole silhouette is drawn, holes and all.',
    stage: ExampleStage.desk,
    source: 'ticket/ticket_admit_one_example.dart',
    builder: TicketAdmitOneExample.new,
  ),
  GalleryExample(
    title: 'Stocks, stubs, used',
    description:
        'Kraft, cream, cinema yellow and tram-ticket pink. The stub can be at the start, wider, or not there; a punched hole says it has been used.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'ticket/ticket_stocks_and_stubs_example.dart',
    builder: TicketStocksAndStubsExample.new,
  ),
  GalleryExample(
    title: 'Taped to the page',
    description:
        'A ticket is an ordinary box: tape and stamps go on it with a plain Stack. Its shadow follows the notches and the holes.',
    stage: ExampleStage.desk,
    source: 'ticket/ticket_clipped_example.dart',
    builder: TicketClippedExample.new,
  ),
  GalleryExample(
    title: 'Your tickets',
    description:
        'A real list: tickets with an action, a status, and a punched hole once used. The state lives in your app; the ticket only shows it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'ticket/ticket_event_tickets_example.dart',
    builder: TicketEventTicketsExample.new,
  ),
];
