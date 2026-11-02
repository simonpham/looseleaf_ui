import 'package:gallery/features/components/examples/icon/icon.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/icon/`.
const iconExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Sixteen pixels, ink in the current text color. Names are lucide\'s, so a shadcn snippet keeps working.',
    source: 'icon/icon_default_example.dart',
    builder: IconDefaultExample.new,
  ),
  GalleryExample(
    title: 'Redrawn, not scaled',
    description:
        'Each size is its own drawing: 12 px is one confident stroke, 16 px is heavier and simpler than 24, 48 px gets its extras.',
    source: 'icon/icon_sizes_example.dart',
    builder: IconSizesExample.new,
  ),
  GalleryExample(
    title: 'UI and doodle tone',
    description:
        'In UI tone an icon is ink only. In doodle tone its accent wash shows, and `accent` picks another color.',
    source: 'icon/icon_tones_example.dart',
    builder: IconTonesExample.new,
  ),
  GalleryExample(
    title: 'In real UI',
    description:
        'Status rows and three real buttons (an icon with a label, an icon on its own, a label with a chevron): color comes from the parent, size from `size`, and inside a Button the icon takes the button\'s own size.',
    layout: ExampleLayout.stack,
    source: 'icon/icon_in_context_example.dart',
    builder: IconInContextExample.new,
  ),
  GalleryExample(
    title: 'Every icon drawn so far',
    description:
        'The gallery grows by itself as icon batches land. Names are the lucide ids; hover-free, so it doubles as a search list.',
    layout: ExampleLayout.stack,
    source: 'icon/icon_gallery_example.dart',
    builder: IconGalleryExample.new,
  ),
];
