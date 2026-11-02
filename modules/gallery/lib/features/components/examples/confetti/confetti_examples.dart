import 'package:gallery/features/components/examples/confetti/confetti.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/confetti/`.
const confettiExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Click the button. Pieces leave it in a cone, slow down like paper, sway and fade.',
    height: 240,
    source: 'confetti/confetti_default_example.dart',
    builder: ConfettiDefaultExample.new,
  ),
  GalleryExample(
    title: 'Ring, streamers, one color',
    description: 'spread 360 sends a ring; shapes and colors narrow the pieces. A Valentine\'s burst of pink dots and stars.',
    height: 260,
    source: 'confetti/confetti_ring_and_shapes_example.dart',
    builder: ConfettiRingAndShapesExample.new,
  ),
  GalleryExample(
    title: 'Finishing the list',
    description: 'A real use: confetti stays inside the card and goes off when the last task is ticked. Untick one and tick it again for another go.',
    stage: ExampleStage.desk,
    height: 330,
    source: 'confetti/confetti_task_done_example.dart',
    builder: ConfettiTaskDoneExample.new,
  ),
];
