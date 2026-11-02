import 'package:gallery/features/components/examples/underline/underline.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/underline/`.
const underlineExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A felt-tip line under a phrase. It rises a little to the right, starts a hair early and runs past the last letter.',
    layout: ExampleLayout.stack,
    source: 'underline/underline_default_example.dart',
    builder: UnderlineDefaultExample.new,
  ),
  GalleryExample(
    title: 'Kinds and pens',
    description:
        'Single, double, wavy and scribbled lines; felt, blue felt, red felt, pencil and marker; fine, regular and brush.',
    layout: ExampleLayout.stack,
    source: 'underline/underline_kinds_and_pens_example.dart',
    builder: UnderlineKindsAndPensExample.new,
  ),
  GalleryExample(
    title: 'Wraps, and draws on',
    description:
        'An underline that wraps onto several lines is one pull per line. Press replay to watch it being drawn.',
    layout: ExampleLayout.stack,
    height: 220,
    source: 'underline/underline_wrapping_example.dart',
    builder: UnderlineWrappingExample.new,
  ),
  GalleryExample(
    title: 'Under a headline',
    description:
        'A double brush line under a title, a wavy pencil line under a caption: the pen grows with the type.',
    stage: ExampleStage.desk,
    source: 'underline/underline_headline_example.dart',
    builder: UnderlineHeadlineExample.new,
  ),
];
