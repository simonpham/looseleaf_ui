import 'package:gallery/features/components/examples/arrow/arrow.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/arrow/`.
const arrowExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A straight arrow in its 80 x 40 box. The tail sits a hair lower than the head, like a real one.',
    source: 'arrow/arrow_default_example.dart',
    builder: ArrowDefaultExample.new,
  ),
  GalleryExample(
    title: 'Directions, shafts and heads',
    description:
        'Eight directions, each straight and curved; then the curl and the five heads.',
    layout: ExampleLayout.stack,
    source: 'arrow/arrow_directions_and_curves_example.dart',
    builder: ArrowDirectionsAndCurvesExample.new,
  ),
  GalleryExample(
    title: 'Pointing at an element',
    description:
        'Give it a GlobalKey and the arrow leaves its small box and stops just short of the target, wherever the layout puts it. Resize the window and it follows.',
    layout: ExampleLayout.stack,
    height: 260,
    source: 'arrow/arrow_point_at_example.dart',
    builder: ArrowPointAtExample.new,
  ),
  GalleryExample(
    title: 'With a label',
    description:
        'A label is real handwritten text, placed outside the tail on the side the arrow leaves from. Here it leaves the note at the top right and lands on the signature line.',
    stage: ExampleStage.desk,
    height: 300,
    source: 'arrow/arrow_labelled_example.dart',
    builder: ArrowLabelledExample.new,
  ),
];
