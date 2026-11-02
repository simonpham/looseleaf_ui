import 'package:gallery/features/components/examples/handwritten/handwritten.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/handwritten/`.
const handwrittenExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Typeset on the left, written on the right: the same words, the same size.',
    layout: ExampleLayout.stack,
    source: 'handwritten/handwritten_default_example.dart',
    builder: HandwrittenDefaultExample.new,
  ),
  GalleryExample(
    title: 'Strength, and what it leaves alone',
    description: '0.5, 1 and 2. Code, keys and links inside are never touched; a WidgetSpan opts anything else out.',
    layout: ExampleLayout.stack,
    source: 'handwritten/handwritten_strength_and_skips_example.dart',
    builder: HandwrittenStrengthAndSkipsExample.new,
  ),
  GalleryExample(
    title: 'A sticky note',
    description: 'Handwritten inside a sticky note: the sheet turns a little, the words only jitter.',
    stage: ExampleStage.desk,
    source: 'handwritten/handwritten_sticky_note_example.dart',
    builder: HandwrittenStickyNoteExample.new,
  ),
];
