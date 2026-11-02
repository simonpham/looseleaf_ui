import 'package:gallery/features/components/examples/typing_indicator/typing_indicator.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/typing-indicator/`.
const typingIndicatorExamples = <GalleryExample>[
  GalleryExample(
    title: 'Three dots and a scrawl',
    description:
        'The pencil writes the dots one after another, walks back and starts again. The second variant scrawls a line of cursive instead.',
    source: 'typing_indicator/typing_indicator_default_example.dart',
    builder: TypingIndicatorDefaultExample.new,
  ),
  GalleryExample(
    title: 'Inside a bubble',
    description:
        'Put it in a BubbleContent and the bubble draws itself round it. Keep the region mounted and exposed (hide the bubble visually, keep its semantics) and toggle `active`, so assistive tech announces it.',
    layout: ExampleLayout.stack,
    source: 'typing_indicator/typing_indicator_in_a_bubble_example.dart',
    builder: TypingIndicatorInABubbleExample.new,
  ),
  GalleryExample(
    title: 'Who is typing',
    description:
        'A message row with an avatar, a header and the indicator in blue felt for the person on the other end. The label names them for screen readers.',
    layout: ExampleLayout.stack,
    source: 'typing_indicator/typing_indicator_status_example.dart',
    builder: TypingIndicatorStatusExample.new,
  ),
];
