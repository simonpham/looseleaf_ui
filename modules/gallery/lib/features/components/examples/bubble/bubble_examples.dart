import 'package:gallery/features/components/examples/bubble/bubble.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/bubble/`.
const bubbleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Variants',
    description:
        "Marker, highlighter, paper shade, a marker wash, paper and a line, red pencil hatching, and nothing at all. The tail sits on the sender's side.",
    layout: ExampleLayout.stack,
    source: 'bubble/bubble_variants_example.dart',
    builder: BubbleVariantsExample.new,
  ),
  GalleryExample(
    title: 'A conversation',
    description:
        'Bubbles inside Messages: the tail follows the sender, the earlier bubbles of a run lose theirs, a reaction chip sits on the edge, and the header and footer are hand notes.',
    layout: ExampleLayout.stack,
    source: 'bubble/bubble_conversation_example.dart',
    builder: BubbleConversationExample.new,
  ),
  GalleryExample(
    title: 'Notes, stickies and your own hand',
    description:
        'A bubble does not have to be a cloud. A note is a slip of paper folded twice, a sticky is a sticky note, and `pen: BubblePen.you` writes in blue felt and the script font.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'bubble/bubble_shapes_example.dart',
    builder: BubbleShapesExample.new,
  ),
  GalleryExample(
    title: 'Bubbles as buttons',
    description:
        'onPressed turns a bubble into a real button: it wobbles on hover (drop-lines), draws a blue ring on keyboard focus, and can be pressed. Good for suggested replies.',
    layout: ExampleLayout.stack,
    source: 'bubble/bubble_suggestions_example.dart',
    builder: BubbleSuggestionsExample.new,
  ),
];
