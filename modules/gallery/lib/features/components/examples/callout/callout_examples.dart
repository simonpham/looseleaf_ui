import 'package:gallery/features/components/examples/callout/callout.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/callout/`.
const calloutExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Handwritten words and an arrow that points left, at whatever is to their left.',
    source: 'callout/callout_default_example.dart',
    builder: CalloutDefaultExample.new,
  ),
  GalleryExample(
    title: 'Eight directions',
    description: 'The arrow points where you say; the words sit on its tail.',
    layout: ExampleLayout.stack,
    source: 'callout/callout_directions_example.dart',
    builder: CalloutDirectionsExample.new,
  ),
  GalleryExample(
    title: 'In the margin of a paragraph',
    description: 'Set callouts in the page\'s margin beside the words they are about, on the same rules as the text. On narrow pages they are hidden.',
    stage: ExampleStage.desk,
    source: 'callout/callout_margin_notes_example.dart',
    builder: CalloutMarginNotesExample.new,
  ),
  GalleryExample(
    title: 'A hint on a form',
    description: 'Positioned over a form: a hint that points at the field it is about, that writes itself on when it appears and goes away once the field takes focus.',
    height: 320,
    source: 'callout/callout_onboarding_example.dart',
    builder: CalloutOnboardingExample.new,
  ),
];
