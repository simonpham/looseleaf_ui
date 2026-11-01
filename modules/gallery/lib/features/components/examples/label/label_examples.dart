import 'package:gallery/features/components/examples/label/label.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/label/`.
const labelExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Click the words and the field takes focus.',
    layout: ExampleLayout.stack,
    source: 'label/label_default_example.dart',
    builder: LabelDefaultExample.new,
  ),
  GalleryExample(
    title: 'Required',
    description: 'The star is drawn, not typed, and it is decorative: required on the control is what a screen reader hears.',
    layout: ExampleLayout.stack,
    source: 'label/label_required_example.dart',
    builder: LabelRequiredExample.new,
  ),
  GalleryExample(
    title: 'Dimmed with a disabled control',
    description: 'A label beside a disabled control fades to graphite: next to a checkbox, above a drawn Input, or for a whole disabled group.',
    layout: ExampleLayout.stack,
    source: 'label/label_disabled_peer_example.dart',
    builder: LabelDisabledPeerExample.new,
  ),
  GalleryExample(
    title: 'Accept terms',
    description: "shadcn's `label-demo`: a Label next to a Checkbox. Click the words and the box ticks itself.",
    source: 'label/label_terms_example.dart',
    builder: LabelTermsExample.new,
  ),
];
