import 'package:gallery/features/components/examples/bookmark/bookmark.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/bookmark/`.
const bookmarkExamples = <GalleryExample>[
  GalleryExample(
    title: 'A bookmark',
    description: 'Press it: the ghost becomes a ribbon that settles in with a little turn. It is a toggle button, so Space and Enter work, and screen readers hear its pressed state.',
    stage: ExampleStage.desk,
    source: 'bookmark/bookmark_default_example.dart',
    builder: BookmarkDefaultExample.new,
  ),
  GalleryExample(
    title: 'Eight ribbons',
    description: 'Every stationery accent. Each ribbon is woven and edge-stitched, lit from the upper left, a hair off straight.',
    stage: ExampleStage.desk,
    source: 'bookmark/bookmark_tones_example.dart',
    builder: BookmarkTonesExample.new,
  ),
  GalleryExample(
    title: 'Page markers',
    description: 'BookmarkRibbon is the ribbon with no behavior: decoration that hangs out of the top of a sheet or a notebook.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'bookmark/bookmark_page_markers_example.dart',
    builder: BookmarkPageMarkersExample.new,
  ),
  GalleryExample(
    title: 'A reading list',
    description: 'A real use: save articles for later. Each card holds a Bookmark; the count follows. State lives in your app, as with any toggle.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'bookmark/bookmark_reading_list_example.dart',
    builder: BookmarkReadingListExample.new,
  ),
];
