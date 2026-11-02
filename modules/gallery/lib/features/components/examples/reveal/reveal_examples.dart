import 'package:gallery/features/components/examples/reveal/reveal.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/reveal/`.
const revealExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'The heading is drawn on left to right as it comes in, once, with a marker tip writing it (nib). Replay builds it again with a new key.',
    layout: ExampleLayout.stack,
    source: 'reveal/reveal_default_example.dart',
    builder: RevealDefaultExample.new,
  ),
  GalleryExample(
    title: 'Five arrivals',
    description:
        "wipe, soak, drop, pop and toss, each one of the theme's keyframes. They play when they are first built.",
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'reveal/reveal_effects_example.dart',
    builder: RevealEffectsExample.new,
  ),
  GalleryExample(
    title: 'A list that arrives line by line',
    description:
        'A real use: Reveal.stagger makes its children arrive one after another, each drying like wet ink.',
    layout: ExampleLayout.stack,
    source: 'reveal/reveal_feature_list_example.dart',
    builder: RevealFeatureListExample.new,
  ),
];
