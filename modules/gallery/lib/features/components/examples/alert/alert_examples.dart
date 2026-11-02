import 'package:gallery/features/components/examples/alert/alert.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/alert/`.
const alertExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default and destructive',
    description: 'The two upstream variants. An icon put first is circled in the alert\'s marker; the destructive alert is told apart by red hatching in its margin, not by red alone.',
    layout: ExampleLayout.stack,
    source: 'alert/alert_default_example.dart',
    builder: AlertDefaultExample.new,
  ),
  GalleryExample(
    title: 'Tones and patterns',
    description: '`info`, `success` and `warning` are additions. Each has its own pattern in the margin: a double blue pencil rule, a strip of green marker, a panel of highlighter. Without an icon there is no circle, and without a title the description is one plain line.',
    layout: ExampleLayout.stack,
    source: 'alert/alert_tones_example.dart',
    builder: AlertTonesExample.new,
  ),
  GalleryExample(
    title: 'Sticky note',
    description: '`AlertTone.note` is a sticky note with a taped corner: a Paper, so the sheet turns a little and the text does not. Use it for asides that should not look like system messages.',
    stage: ExampleStage.desk,
    height: 220,
    source: 'alert/alert_note_example.dart',
    builder: AlertNoteExample.new,
  ),
  GalleryExample(
    title: 'In a billing card',
    description: 'A real use: the alert leads the card\'s content, carries an action button of its own (a separate host, with its own ring and hover) and goes away once it is dealt with. It is a live region, so screen readers hear it when it appears.',
    height: 420,
    source: 'alert/alert_billing_example.dart',
    builder: AlertBillingExample.new,
  ),
  GalleryExample(
    title: 'Icon, title, description: any combination',
    description: 'The shadcn demo. An alert needs no description (icon and a title on one line) and no title (icon and a sentence), and a success message can say everything in three parts. The icon is circled in the alert\'s own pen.',
    layout: ExampleLayout.stack,
    source: 'alert/alert_icon_and_title_example.dart',
    builder: AlertIconAndTitleExample.new,
  ),
  GalleryExample(
    title: 'Session expired',
    description: 'The smallest destructive alert: an icon, the word Error and one plain sentence. Below it, the same message with the way out built in. Alerts are live regions, so the second one is announced when it appears.',
    layout: ExampleLayout.stack,
    source: 'alert/alert_session_expired_example.dart',
    builder: AlertSessionExpiredExample.new,
  ),
];
