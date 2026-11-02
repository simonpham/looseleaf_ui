import 'package:gallery/features/components/examples/bracket/bracket.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/bracket/`.
const bracketExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A square bracket down the start side of two paragraphs.',
    layout: ExampleLayout.stack,
    source: 'bracket/bracket_default_example.dart',
    builder: BracketDefaultExample.new,
  ),
  GalleryExample(
    title: 'Kinds and sides',
    description:
        'Square, curly and round; on the start side and the end side; in ink, blue and red.',
    layout: ExampleLayout.stack,
    source: 'bracket/bracket_kinds_and_sides_example.dart',
    builder: BracketKindsAndSidesExample.new,
  ),
  GalleryExample(
    title: 'Grouping list items',
    description:
        'A curly brace across three items with a note on the other side: the list is still a list.',
    source: 'bracket/bracket_list_group_example.dart',
    builder: BracketListGroupExample.new,
  ),
];
