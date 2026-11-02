import 'package:gallery/features/components/examples/envelope/envelope.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/envelope/`.
const envelopeExamples = <GalleryExample>[
  GalleryExample(
    title: 'An envelope',
    description:
        'Press it, or Tab to it and press Space: the flap stands up behind and the letter slides out. Hover lifts the flap a sliver.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'envelope/envelope_default_example.dart',
    builder: EnvelopeDefaultExample.new,
  ),
  GalleryExample(
    title: 'Manila, white, airmail',
    description:
        'Kraft (the default), white paper with a sky-blue stamp, and an airmail envelope with its striped border. Each stamp is perforated; each has a postmark over it.',
    stage: ExampleStage.desk,
    source: 'envelope/envelope_stocks_and_airmail_example.dart',
    builder: EnvelopeStocksAndAirmailExample.new,
  ),
  GalleryExample(
    title: 'Opens when you look',
    description:
        '`openOnHover` opens it under a mouse and closes it again on leaving, unless you clicked it open. On touch and keyboard the trigger works as always.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'envelope/envelope_open_on_hover_example.dart',
    builder: EnvelopeOpenOnHoverExample.new,
  ),
  GalleryExample(
    title: 'An inbox',
    description:
        'A real use: messages that arrive as envelopes. Opening one marks it read; only one is open at a time. State lives in your app; the envelope only shows it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 560,
    source: 'envelope/envelope_inbox_example.dart',
    builder: EnvelopeInboxExample.new,
  ),
];
