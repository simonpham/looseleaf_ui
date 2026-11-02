import 'package:gallery/features/components/examples/direction/direction.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/direction/`.
const directionExamples = <GalleryExample>[
  GalleryExample(
    title: 'Reading direction',
    description: "One provider, one prop. Flip it and the keys, the slider's start edge, the tab shoulders and the words all turn round together. Click a tab and press the arrow keys before and after.",
    height: 360,
    source: 'direction/direction_reading_direction_example.dart',
    builder: DirectionReadingDirectionExample.new,
  ),
  GalleryExample(
    title: 'Arabic: notebook',
    description: 'Tabs, a menu with a sub-menu, a slider and a table, in Arabic. Tab and arrow keys run right to left, the sub-menu opens with ArrowLeft, the slider starts at its right edge, the table columns read from the right.',
    height: 640,
    source: 'direction/direction_arabic_notebook_example.dart',
    builder: DirectionArabicNotebookExample.new,
  ),
  GalleryExample(
    title: 'Hebrew: pages',
    description: 'A breadcrumb, a carousel and a pager, in Hebrew. The separators and arrows are the same drawings as in English: direction glyphs flip themselves, so the first slide sits at the right and ArrowLeft moves on to the next.',
    height: 480,
    source: 'direction/direction_hebrew_pages_example.dart',
    builder: DirectionHebrewPagesExample.new,
  ),
  GalleryExample(
    title: 'Arabic: sidebar',
    description: 'The pad hangs on the right, where a right-to-left page keeps its margin: SidebarSide.right is a physical side, so you choose it. The clip, the highlighter, the bracket, the panel icon and the sheet on a phone all follow.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 520,
    source: 'direction/direction_arabic_sidebar_example.dart',
    builder: DirectionArabicSidebarExample.new,
  ),
  GalleryExample(
    title: 'DirectionProvider.of and islands',
    description: 'Your own widgets can read the direction too. This pager decides which arrow key goes forward from DirectionProvider.of, and its arrow drawings flip themselves. The English block is a left-to-right island inside the Hebrew page: it has its own provider, and its popover opens left to right.',
    height: 460,
    source: 'direction/direction_use_direction_example.dart',
    builder: DirectionUseDirectionExample.new,
  ),
];
