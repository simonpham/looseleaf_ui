import 'package:gallery/features/components/examples/tally/tally.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/tally/`.
const tallyExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Seven: one bundle struck through and two more. size takes sm, md or lg, and glyphHeight a number of pixels. The number is what a screen reader hears.',
    source: 'tally/tally_default_example.dart',
    builder: TallyDefaultExample.new,
  ),
  GalleryExample(
    title: 'Counts, sizes and pens',
    description:
        'Add a mark and watch the bundles build. Sizes sm, md, lg; ink, blue, red and pencil pens.',
    layout: ExampleLayout.stack,
    source: 'tally/tally_counts_and_sizes_example.dart',
    builder: TallyCountsAndSizesExample.new,
  ),
  GalleryExample(
    title: 'A vote board',
    description:
        'Tallies beside the words they count. Each has its own accessible name ("12 votes for tea").',
    stage: ExampleStage.desk,
    source: 'tally/tally_vote_board_example.dart',
    builder: TallyVoteBoardExample.new,
  ),
];
