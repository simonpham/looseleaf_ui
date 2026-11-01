import 'package:gallery/features/components/examples/badge/badge.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/badge/`.
const badgeExamples = <GalleryExample>[
  GalleryExample(
    title: 'Variants',
    description: 'A marker stamp, a highlighter swipe, a red-hatched pill, a circled word, and two that only show up when they are links.',
    layout: ExampleLayout.stack,
    source: 'badge/badge_variants_example.dart',
    builder: BadgeVariantsExample.new,
  ),
  GalleryExample(
    title: 'Sizes, icons and tones',
    description: 'Three heights, an icon slot in front of the label (the icon keeps its own 14 px drawing), and the stationery accents for the marker fill.',
    layout: ExampleLayout.stack,
    source: 'badge/badge_sizes_icons_tones_example.dart',
    builder: BadgeSizesIconsTonesExample.new,
  ),
  GalleryExample(
    title: 'Counts and tally marks',
    description: 'A number in tabular figures that stops at 99+, and the same number written the way a person keeps score: four uprights and a slash. Screen readers get the digits either way.',
    layout: ExampleLayout.stack,
    source: 'badge/badge_counts_and_tally_example.dart',
    builder: BadgeCountsAndTallyExample.new,
  ),
  GalleryExample(
    title: 'As a link',
    description: 'onPressed turns the badge into a link. Hover a link badge: the filled ones lift a drop-line, the outline gets a highlighter wash, ghost swipes and link underlines. Tab to it for the felt ring.',
    layout: ExampleLayout.stack,
    source: 'badge/badge_as_link_example.dart',
    builder: BadgeAsLinkExample.new,
  ),
  GalleryExample(
    title: 'Release notes',
    description: 'Badges doing real work in a card: a status next to the title, the kind of each change in front of its line, and a tally of how many are left to read.',
    layout: ExampleLayout.stack,
    source: 'badge/badge_release_notes_example.dart',
    builder: BadgeReleaseNotesExample.new,
  ),
];
