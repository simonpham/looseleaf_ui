import 'package:gallery/features/components/examples/radio_group/radio_group.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/radio-group/`.
const radioGroupExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Pick one. The choice is circled, then colored in: a terracotta blot with a felt spiral written into it. Arrow keys move the choice.',
    layout: ExampleLayout.stack,
    source: 'radio_group/radio_group_default_example.dart',
    builder: RadioGroupDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes and states',
    description: '16, 20 and 28 px; off, on, invalid (red pencil, still red on top of the dot) and disabled (dashed, graphite dot). A horizontal group lays its radios in a row.',
    layout: ExampleLayout.stack,
    source: 'radio_group/radio_group_states_example.dart',
    builder: RadioGroupStatesExample.new,
  ),
  GalleryExample(
    title: 'Plan picker',
    description: 'Radios with a title and a line of help, and a second horizontal group for billing. Hovering the row lights its radio; the description is part of the label, so screen readers read both.',
    layout: ExampleLayout.stack,
    source: 'radio_group/radio_group_plans_example.dart',
    builder: RadioGroupPlansExample.new,
  ),
  GalleryExample(
    title: 'In a form',
    description: 'The chosen value is plain state, and the vote is blocked (the group turns invalid) until one is picked.',
    layout: ExampleLayout.stack,
    source: 'radio_group/radio_group_in_a_form_example.dart',
    builder: RadioGroupInAFormExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `radio-group-demo`: three options, the middle one chosen. Click, or focus the group and use the arrow keys; the chosen ring gets its dot written in.',
    source: 'radio_group/radio_group_demo_example.dart',
    builder: RadioGroupDemoExample.new,
  ),
];
