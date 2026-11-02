import 'package:gallery/features/components/examples/paper/paper.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/paper/`.
const paperExamples = <GalleryExample>[
  GalleryExample(
    title: 'Stocks',
    description:
        'Paper is a recipe: a color, a tooth, a shadow and the rules printed on it. Each stock lies at its own small angle.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'paper/paper_stocks_example.dart',
    builder: PaperStocksExample.new,
  ),
  GalleryExample(
    title: 'Edges',
    description:
        'A plain cut is pure CSS. Torn, deckled, pinked, perforated and scalloped edges draw their outline once, with a fringe of torn fibers.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'paper/paper_edges_example.dart',
    builder: PaperEdgesExample.new,
  ),
  GalleryExample(
    title: 'Taped, pinned, clipped',
    description:
        'The tape shorthand lays strips across a corner, along the top or across both corners. A fastener holds a sheet with a clip, a pin, a staple or a binder clip.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'paper/paper_taped_and_pinned_example.dart',
    builder: PaperTapedAndPinnedExample.new,
  ),
  GalleryExample(
    title: 'Ruled notes',
    description:
        'Printed rules are part of the sheet, so they turn with it and the text stays upright. Set the line height to the rule pitch (28 px) and start the first line 16 px down and the words sit on the lines, baseline 2 to 3 px above the rule. Each rule is printed 8 px above the bottom of its line; rulesOffset tunes that.',
    layout: ExampleLayout.stack,
    source: 'paper/paper_ruled_note_example.dart',
    builder: PaperRuledNoteExample.new,
  ),
  GalleryExample(
    title: 'A wall of sticky notes',
    description:
        'Sticky notes are turned a little more than pages, cast a shadow that lifts at the foot, and can curl a corner. One note per meaning; the first word says what it is.',
    layout: ExampleLayout.stack,
    source: 'paper/paper_sticky_wall_example.dart',
    builder: PaperStickyWallExample.new,
  ),
  GalleryExample(
    title: 'A receipt',
    description:
        'Thermal paper with pinked top and bottom, a mono print and a dashed total. The receipt stock is the same recipe as every other, cut differently.',
    layout: ExampleLayout.stack,
    source: 'paper/paper_receipt_example.dart',
    builder: PaperReceiptExample.new,
  ),
];
