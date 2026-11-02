import 'package:gallery/features/components/examples/sketchpad/sketchpad.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sketchpad/`.
const sketchpadExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Draw with the mouse, a finger or a pen. Every line is written by the same pen as the buttons: pressure swells it, felt pools where you stop, pencil has tooth.',
    layout: ExampleLayout.stack,
    source: 'sketchpad/sketchpad_default_example.dart',
    builder: SketchpadDefaultExample.new,
  ),
  GalleryExample(
    title: 'Every pen',
    description: 'Felt, brush, pencil, marker and highlighter on one page. Same points, five materials: the grain and the blend come from the pen, not from the data.',
    layout: ExampleLayout.stack,
    source: 'sketchpad/sketchpad_every_pen_example.dart',
    builder: SketchpadEveryPenExample.new,
  ),
  GalleryExample(
    title: 'Replay',
    description: 'A read-only sketchpad that draws itself on again, stroke after stroke, along each center line. Reduced motion shows the finished picture.',
    layout: ExampleLayout.stack,
    source: 'sketchpad/sketchpad_replay_example.dart',
    builder: SketchpadReplayExample.new,
  ),
  GalleryExample(
    title: 'Your own toolbar',
    description: 'The parts compose. A pencil-and-eraser sketchbook on graph paper, four colors, with a plot already begun.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sketchpad/sketchpad_graph_paper_example.dart',
    builder: SketchpadGraphPaperExample.new,
  ),
  GalleryExample(
    title: 'Postcard',
    description: 'A real use: draw a card, watch a live thumbnail (the same strokes, read-only), copy the picture as SVG or copy the JSON to keep it in your database.',
    layout: ExampleLayout.stack,
    height: 420,
    source: 'sketchpad/sketchpad_postcard_example.dart',
    builder: SketchpadPostcardExample.new,
  ),
];
