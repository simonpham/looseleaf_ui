import 'package:gallery/features/components/examples/marquee/marquee.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/marquee/`.
const marqueeExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Point at it and it stops; so does Tab. The round button pauses it for good.',
    stage: ExampleStage.desk,
    source: 'marquee/marquee_default_example.dart',
    builder: MarqueeDefaultExample.new,
  ),
  GalleryExample(
    title: 'Tapes and directions',
    description:
        'Any tape from the desk: masking, striped, gingham. MarqueeDirection.end runs it the other way, speed sets px per second. (washiDots is for short, large words: its white dots are as big as small letters.)',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'marquee/marquee_tapes_example.dart',
    builder: MarqueeTapesExample.new,
  ),
  GalleryExample(
    title: 'Announcement bar',
    description:
        'A real use: the strip above a site header, with links in it. Only the first copy can be tabbed to, and the ticker holds still while a link has focus.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'marquee/marquee_announcement_bar_example.dart',
    builder: MarqueeAnnouncementBarExample.new,
  ),
];
