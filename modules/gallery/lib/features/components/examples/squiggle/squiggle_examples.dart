import 'package:gallery/features/components/examples/squiggle/squiggle.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/squiggle/`.
const squiggleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A wavy line across the width, between two paragraphs.',
    layout: ExampleLayout.stack,
    source: 'squiggle/squiggle_default_example.dart',
    builder: SquiggleDefaultExample.new,
  ),
  GalleryExample(
    title: 'Six kinds, and vertical',
    description:
        'Wave, zig-zag, loops, scallops, dashes and dots; then the same patterns standing up.',
    layout: ExampleLayout.stack,
    source: 'squiggle/squiggle_kinds_example.dart',
    builder: SquiggleKindsExample.new,
  ),
  GalleryExample(
    title: 'Between sections of a card',
    description:
        'A real separator (decorative: false) that draws itself on when the card scrolls into view.',
    stage: ExampleStage.desk,
    source: 'squiggle/squiggle_section_divider_example.dart',
    builder: SquiggleSectionDividerExample.new,
  ),
];
