import 'package:gallery/features/components/examples/scribble/scribble.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/scribble/`.
const scribbleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A word scribbled out in ink. The strokes lean, vary in pitch and spill past the letters.',
    layout: ExampleLayout.stack,
    source: 'scribble/scribble_default_example.dart',
    builder: ScribbleDefaultExample.new,
  ),
  GalleryExample(
    title: 'Pens',
    description:
        'Ink brush, a fine liner that leaves the words readable, red felt, blue felt and soft pencil: one change of mind each.',
    layout: ExampleLayout.stack,
    source: 'scribble/scribble_pens_example.dart',
    builder: ScribblePensExample.new,
  ),
  GalleryExample(
    title: 'An edited draft',
    description:
        "Scribbles, strikes and a highlight on the same page: an editor's pass over a paragraph.",
    stage: ExampleStage.desk,
    source: 'scribble/scribble_edited_draft_example.dart',
    builder: ScribbleEditedDraftExample.new,
  ),
];
