import 'package:gallery/features/components/examples/doodle/doodle.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/doodle/`.
const doodleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: '96 px: line-led, one marker fill that misses the outline, a light pencil shading in the lower right.',
    source: 'doodle/doodle_default_example.dart',
    builder: DoodleDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes are redrawn',
    description: 'Below 72 px a doodle switches to its 48 px drawing: the silhouette and one identifying detail, drawn with a heavier line.',
    source: 'doodle/doodle_sizes_example.dart',
    builder: DoodleSizesExample.new,
  ),
  GalleryExample(
    title: 'In the margin',
    description: 'Doodles live in the decoration layer: turned a few degrees, tucked in the corner of a card, next to a title.',
    layout: ExampleLayout.stack,
    source: 'doodle/doodle_margin_example.dart',
    builder: DoodleMarginExample.new,
  ),
  GalleryExample(
    title: 'Every doodle drawn so far',
    description: 'Grows by itself as the doodle batches land.',
    layout: ExampleLayout.stack,
    source: 'doodle/doodle_gallery_example.dart',
    builder: DoodleGalleryExample.new,
  ),
];
