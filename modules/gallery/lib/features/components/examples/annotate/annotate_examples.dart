import 'package:gallery/features/components/examples/annotate/annotate.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/annotate/`.
const annotateExamples = <GalleryExample>[
  GalleryExample(
    title: 'Playground: a reader\'s page',
    description:
        'One paragraph annotated the way a reader does it: a circle, two highlighters, a red underline, a struck phrase, a wavy line and margin notes with arrows. Switch each on and off, or replay the whole page being marked up.',
    stage: ExampleStage.desk,
    height: 470,
    source: 'annotate/annotate_playground_example.dart',
    builder: AnnotatePlaygroundExample.new,
  ),
  GalleryExample(
    title: 'Every type',
    description:
        'The eight marks side by side. Each is a real component underneath (Highlight, Underline, Circled, Strike, Scribble) with the same props.',
    layout: ExampleLayout.stack,
    source: 'annotate/annotate_every_type_example.dart',
    builder: AnnotateEveryTypeExample.new,
  ),
  GalleryExample(
    title: 'Colors and weights',
    description:
        'A highlighter takes a tone; every other mark takes a pen. Fine-liner, felt tip or brush.',
    layout: ExampleLayout.stack,
    source: 'annotate/annotate_colours_example.dart',
    builder: AnnotateColoursExample.new,
  ),
  GalleryExample(
    title: 'An editor\'s pass',
    description:
        'Turn the review on and the draft is marked up in sequence: words crossed out, a phrase scribbled, another bracketed. Nothing is removed from the text.',
    stage: ExampleStage.desk,
    height: 320,
    source: 'annotate/annotate_review_example.dart',
    builder: AnnotateReviewExample.new,
  ),
];
