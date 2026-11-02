import 'package:gallery/features/components/examples/highlight/highlight.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/highlight/`.
const highlightExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A swipe behind a phrase. Select the text, copy it: it is still just words.',
    layout: ExampleLayout.stack,
    source: 'highlight/highlight_default_example.dart',
    builder: HighlightDefaultExample.new,
  ),
  GalleryExample(
    title: 'Tones and weights',
    description:
        'Yellow is the highlighter. Pink, green, blue, orange, lilac and teal are the stationery accents held as translucent markers.',
    layout: ExampleLayout.stack,
    source: 'highlight/highlight_tones_example.dart',
    builder: HighlightTonesExample.new,
  ),
  GalleryExample(
    title: 'Wraps, and draws on',
    description:
        'A phrase that runs onto three lines gets three swipes, one per line, that start and stop where the words do. Press replay to watch it being drawn.',
    layout: ExampleLayout.stack,
    height: 220,
    source: 'highlight/highlight_wrapping_example.dart',
    builder: HighlightWrappingExample.new,
  ),
  GalleryExample(
    title: 'Reading notes',
    description:
        'Highlights inside a card: the swipe sits on the paper, behind the words, and the card\'s tilt never touches the text.',
    stage: ExampleStage.desk,
    source: 'highlight/highlight_reading_notes_example.dart',
    builder: HighlightReadingNotesExample.new,
  ),
];
