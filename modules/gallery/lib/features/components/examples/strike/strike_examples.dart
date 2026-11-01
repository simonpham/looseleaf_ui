import 'package:gallery/features/components/examples/strike/strike.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/strike/`.
const strikeExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Red pencil through the old plan. The line tilts a little and pokes out past both ends.',
    layout: ExampleLayout.stack,
    source: 'strike/strike_default_example.dart',
    builder: StrikeDefaultExample.new,
  ),
  GalleryExample(
    title: 'Kinds and pens',
    description: 'A single line, a double line, a cross-out over the whole phrase, and other pens.',
    layout: ExampleLayout.stack,
    source: 'strike/strike_kinds_example.dart',
    builder: StrikeKindsExample.new,
  ),
  GalleryExample(
    title: 'A price that dropped',
    description: 'The old price stays in the text, so nothing is lost to a screen reader; the card says what changed.',
    stage: ExampleStage.desk,
    source: 'strike/strike_price_example.dart',
    builder: StrikePriceExample.new,
  ),
  GalleryExample(
    title: 'A to-do list',
    description: 'Tick a box and the task is struck through in red pencil, drawn on as you tick it.',
    layout: ExampleLayout.stack,
    source: 'strike/strike_todo_example.dart',
    builder: StrikeTodoExample.new,
  ),
];
