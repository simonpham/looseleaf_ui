import 'package:gallery/features/components/examples/mascot/mascot.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/mascot/`.
const mascotExamples = <GalleryExample>[
  GalleryExample(
    title: 'Poses',
    description:
        'Stubby, an original pencil stub drawn as a die-cut sticker: one bold body with a face and nothing else. A pose is a different face, a lean and a doodle.',
    source: 'mascot/mascot_poses_example.dart',
    builder: MascotPosesExample.new,
  ),
  GalleryExample(
    title: 'Sizes are redrawn',
    description:
        'Under 28 px he is a face on a silhouette (two dots and a smile), 32 and 48 px add the blush, the wood and the graphite tip, 96 px is the master, 160 px adds a shine and a ferrule line.',
    source: 'mascot/mascot_sizes_example.dart',
    builder: MascotSizesExample.new,
  ),
  GalleryExample(
    title: 'An empty state',
    description:
        'Where Stubby earns his keep: an empty search, a quiet inbox. The words carry the meaning, so he stays decorative.',
    layout: ExampleLayout.stack,
    source: 'mascot/mascot_empty_state_example.dart',
    builder: MascotEmptyStateExample.new,
  ),
];
