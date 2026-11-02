import 'package:gallery/features/components/examples/scroll_area/scroll_area.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/scroll-area/`.
const scrollAreaExamples = <GalleryExample>[
  GalleryExample(
    title: 'Tags',
    description: "Shadcn's list, with a pencil scroll mark instead of a bar. The mark fades in when the pointer is over the area or it scrolls, and the thumb is a graphite pull that slides down a faint gutter.",
    height: 320,
    source: 'scroll_area/scroll_area_tags_example.dart',
    builder: ScrollAreaTagsExample.new,
  ),
  GalleryExample(
    title: 'Horizontal strip',
    description: '`orientation: horizontal` shows only the horizontal mark. `bleed` pads the viewport by 12 px so the notes\' shadows and any focus ring are not cut at the edge of the strip.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'scroll_area/scroll_area_horizontal_example.dart',
    builder: ScrollAreaHorizontalExample.new,
  ),
  GalleryExample(
    title: 'Both directions',
    description: '`orientation: both` shows both marks; the corner where they meet stays empty. The viewport takes keyboard focus and draws a blue ring inside its edge when it has it.',
    height: 300,
    source: 'scroll_area/scroll_area_both_example.dart',
    builder: ScrollAreaBothExample.new,
  ),
  GalleryExample(
    title: 'Message log',
    description: 'A real screen: a fixed-height log inside a card, with the newest line kept in view, `bleed` so the edge buttons keep their rings, and an input below. The scroll mark shows while the log is being scrolled.',
    height: 480,
    source: 'scroll_area/scroll_area_messages_example.dart',
    builder: ScrollAreaMessagesExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `scroll-area-demo`: fifty version tags with a Separator between each. The box is a dashed pencil edge rather than a rounded border, and the scroll mark is a graphite pull in a faint gutter. Scroll with the wheel, drag the mark, or focus the list and use the arrow keys.',
    height: 320,
    source: 'scroll_area/scroll_area_demo_example.dart',
    builder: ScrollAreaDemoExample.new,
  ),
  GalleryExample(
    title: 'Horizontal demo',
    description: 'Official `scroll-area-horizontal-demo`: a strip of figures that scrolls sideways under the horizontal mark. shadcn shows three stock photographs; here they are polaroids of drawn scenes, so nothing is fetched. `bleed` gives the viewport 12 px so the photos\' shadows are not cut at the edge.',
    stage: ExampleStage.desk,
    source: 'scroll_area/scroll_area_horizontal_demo_example.dart',
    builder: ScrollAreaHorizontalDemoExample.new,
  ),
];
