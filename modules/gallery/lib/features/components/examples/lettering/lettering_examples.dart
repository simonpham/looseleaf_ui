import 'package:gallery/features/components/examples/lettering/lettering.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/lettering/`.
const letteringExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Ink with a marker-colored second pass, printed a hair out of register.',
    source: 'lettering/lettering_default_example.dart',
    builder: LetteringDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes, colors, duotone and wobble',
    description: 'Five sizes; the second color is a token; a duotone print adds a third pass; wobble writes each word a hair off the baseline.',
    layout: ExampleLayout.stack,
    source: 'lettering/lettering_sizes_and_colours_example.dart',
    builder: LetteringSizesAndColoursExample.new,
  ),
  GalleryExample(
    title: 'A poster',
    description:
        'Hero lettering, a lead line and a sticker on a sheet of paper.',
    stage: ExampleStage.desk,
    height: 320,
    source: 'lettering/lettering_poster_example.dart',
    builder: LetteringPosterExample.new,
  ),
];
