import 'package:gallery/features/components/examples/ribbon/ribbon.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/ribbon/`.
const ribbonExamples = <GalleryExample>[
  GalleryExample(
    title: 'A banner',
    description:
        'A band of colored paper with folded, swallow-tailed ends. The words are real text; the paper is drawn behind them and grows with them.',
    source: 'ribbon/ribbon_default_example.dart',
    builder: RibbonDefaultExample.new,
  ),
  GalleryExample(
    title: 'Variants and colors',
    description:
        'Banner (folded tails), swallow (a V notch at both ends) and flag (square at the start). The colors are the ones ink stays readable on; `paper` is a plain white ribbon.',
    source: 'ribbon/ribbon_variants_and_colours_example.dart',
    builder: RibbonVariantsAndColoursExample.new,
  ),
  GalleryExample(
    title: 'On cards and as links',
    description:
        'A flag pinned to a card edge, a banner as a section heading, and a ribbon that is a link: with `onPressed` the drawing becomes the button, which lifts on hover and takes the drawn focus ring.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'ribbon/ribbon_on_a_card_example.dart',
    builder: RibbonOnACardExample.new,
  ),
];
