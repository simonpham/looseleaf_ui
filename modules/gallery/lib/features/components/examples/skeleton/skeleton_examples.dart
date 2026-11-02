import 'package:gallery/features/components/examples/skeleton/skeleton.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/skeleton/`.
const skeletonExamples = <GalleryExample>[
  GalleryExample(
    title: 'Shapes',
    description: 'Whatever shape the class says: text lines, a circle for an avatar, a picture, a row of buttons. Watch one for a few seconds: the outline and the hatch are redrawn three times over, slowly.',
    layout: ExampleLayout.stack,
    source: 'skeleton/skeleton_shapes_example.dart',
    builder: SkeletonShapesExample.new,
  ),
  GalleryExample(
    title: 'A card that has not arrived',
    description: 'The skeleton of a profile card placed inside the real Card, so the page does not jump when the words come in.',
    layout: ExampleLayout.stack,
    source: 'skeleton/skeleton_card_example.dart',
    builder: SkeletonCardExample.new,
  ),
  GalleryExample(
    title: 'From loading to loaded',
    description: 'The skeleton and the content occupy the same room, so nothing moves when the swap happens. The region says it is busy while it waits; press Reload to see it again.',
    layout: ExampleLayout.stack,
    source: 'skeleton/skeleton_loading_to_loaded_example.dart',
    builder: SkeletonLoadingToLoadedExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `skeleton-demo`: an avatar circle beside two lines of text, shaped only by classes. Each placeholder is a pale pencil hatch inside a rough outline that redraws itself slowly (three frames, each starting at its own phase); reduced motion holds it still.',
    source: 'skeleton/skeleton_demo_example.dart',
    builder: SkeletonDemoExample.new,
  ),
  GalleryExample(
    title: 'Card',
    description: 'Official `skeleton-card`: a picture-sized block over two lines of text. The same one-line classes, no props; hundreds of these on a page cost about what one does, because the drawing is CSS masks from a few shared tiles.',
    source: 'skeleton/skeleton_card_demo_example.dart',
    builder: SkeletonCardDemoExample.new,
  ),
];
