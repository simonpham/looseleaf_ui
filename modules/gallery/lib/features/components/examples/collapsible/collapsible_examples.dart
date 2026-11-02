import 'package:gallery/features/components/examples/collapsible/collapsible.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/collapsible/`.
const collapsibleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Starred repositories',
    description:
        'The classic: a heading with a trigger button, one item always shown and the rest folded away. The panel slides open and shut.',
    height: 240,
    source: 'collapsible/collapsible_repositories_example.dart',
    builder: CollapsibleRepositoriesExample.new,
  ),
  GalleryExample(
    title: 'Margin bracket and indicator',
    description:
        '`bracket` writes a brace beside the opened text and lets it soak in; `CollapsibleIndicator` is the same chevron as the accordion\'s and turns over with the panel.',
    height: 260,
    source: 'collapsible/collapsible_bracket_example.dart',
    builder: CollapsibleBracketExample.new,
  ),
  GalleryExample(
    title: 'Show more',
    description:
        'A composed card: the first three lines of a reading list are always there, the rest fold away behind a controlled trigger that says what it will do.',
    height: 420,
    source: 'collapsible/collapsible_show_more_example.dart',
    builder: CollapsibleShowMoreExample.new,
  ),
];
