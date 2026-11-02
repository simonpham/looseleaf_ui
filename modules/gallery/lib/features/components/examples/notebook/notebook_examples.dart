import 'package:gallery/features/components/examples/notebook/notebook.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/notebook/`.
const notebookExamples = <GalleryExample>[
  GalleryExample(
    title: 'A spiral notebook',
    description:
        'Wire coils through punched holes, ruled lines with a red margin, and two more pages peeking out underneath. The words sit on the lines.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'notebook/notebook_default_example.dart',
    builder: NotebookDefaultExample.new,
  ),
  GalleryExample(
    title: 'Four bindings',
    description:
        'A wire spiral, binder rings, a stab-stitched spine in tomato thread, and a reporter\'s pad bound on top. Each is a different drawing; the holes are punched through and the desk shows in them.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'notebook/notebook_bindings_example.dart',
    builder: NotebookBindingsExample.new,
  ),
  GalleryExample(
    title: 'Turning pages',
    description:
        '`curl` folds the corner and `NotebookTurn` is the button over it. Pages are named with `value`; only the current one is shown, and a turned page unfolds from the dog-ear (a clip wipe, no 3D).',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'notebook/notebook_turning_pages_example.dart',
    builder: NotebookTurningPagesExample.new,
  ),
  GalleryExample(
    title: 'A packing list',
    description:
        'A real notebook page: one checkbox per ruled line (each row is exactly 28 px, so the boxes and words sit on the lines), and a sticker stuck to the corner.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'notebook/notebook_trip_planner_example.dart',
    builder: NotebookTripPlannerExample.new,
  ),
  GalleryExample(
    title: 'On the shelf',
    description:
        'The closed notebook: cloth over board, a darker spine stitched to it, an elastic band, and a paper label. Any stationery color, or black.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'notebook/notebook_covers_example.dart',
    builder: NotebookCoversExample.new,
  ),
];
