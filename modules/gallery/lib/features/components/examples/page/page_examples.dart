import 'package:gallery/features/components/examples/page/page.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/page/`.
const pageExamples = <GalleryExample>[
  GalleryExample(
    title: 'A page',
    description:
        'Header, content and footer on a sheet of paper. The title is underlined by hand; the column is centered and as wide as you say.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'page/page_default_example.dart',
    builder: PageDefaultExample.new,
  ),
  GalleryExample(
    title: 'Punched, ringed, stained',
    description:
        '`holes` punches three holes down the start edge (or two across the top); the desk shows through. `reinforced` adds gummed rings, `stain` a coffee ring.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'page/page_punched_example.dart',
    builder: PagePunchedExample.new,
  ),
  GalleryExample(
    title: 'Torn from a pad',
    description:
        '`torn` is a shorthand for the edge. Pair it with a slip, a highlighted title and a tape strip.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'page/page_torn_pad_example.dart',
    builder: PageTornPadExample.new,
  ),
  GalleryExample(
    title: 'A weekly review',
    description:
        'A real page: three-hole punched, a form on it, a sticker stuck to the corner. Everything on the sheet is ordinary, accessible widgets.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'page/page_weekly_review_example.dart',
    builder: PageWeeklyReviewExample.new,
  ),
];
