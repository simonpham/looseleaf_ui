import 'package:gallery/features/components/examples/carousel/carousel.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/carousel/`.
const carouselExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'The shadcn demo: five cards and two arrows. Previous is dashed on the first slide; swipe or drag, click the arrows, or press Left and Right while focus is inside.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'carousel/carousel_default_example.dart',
    builder: CarouselDefaultExample.new,
  ),
  GalleryExample(
    title: 'The tally, several at a time',
    description: 'CarouselDots keeps count like a tally: a stroke per slide, the fifth of each group struck across the four before it, the current one in blue felt (click any to go there). Seven slides, two per view, and a CarouselController drives the caption.',
    stage: ExampleStage.desk,
    height: 380,
    source: 'carousel/carousel_tally_example.dart',
    builder: CarouselTallyExample.new,
  ),
  GalleryExample(
    title: 'Vertical',
    description: 'axis: Axis.vertical: the slides scroll up and down, the arrows sit above and below with up and down arrows, and the keys are ArrowUp and ArrowDown. Give the strip a height with `extent` and the room between slides with `gap`.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'carousel/carousel_vertical_example.dart',
    builder: CarouselVerticalExample.new,
  ),
  GalleryExample(
    title: 'Photo stack (composed)',
    description: "A real use: a trip's snapshots as taped-down polaroids. The line under the tally reads the current photo's date from the carousel (the polaroid already carries its own caption); the tally counts them, and loop keeps both arrows alive.",
    stage: ExampleStage.desk,
    height: 480,
    source: 'carousel/carousel_photos_example.dart',
    builder: CarouselPhotosExample.new,
  ),
  GalleryExample(
    title: 'Sizes: several slides in view',
    description: 'A slide is as wide as `itemFraction` says: `1 / 2` shows two, `1 / 3` three, and `align: CarouselAlign.start` lines the first slide up with the left edge instead of centring it.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'carousel/carousel_sizes_example.dart',
    builder: CarouselSizesExample.new,
  ),
  GalleryExample(
    title: 'Spacing between slides',
    description: 'The gap is the content\'s `gap`: 16 by default, here 4 for a tight row. It mirrors right to left, and vertical carousels space their slides the same way.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'carousel/carousel_spacing_example.dart',
    builder: CarouselSpacingExample.new,
  ),
  GalleryExample(
    title: 'Autoplay',
    description: 'A small autoplay written inline, so no extra package: a widget inside the Carousel steps it on a timer. It holds still while the pointer or focus is on the carousel, never starts for readers who asked for less motion, and has a real Pause button (WCAG 2.2.2).',
    stage: ExampleStage.desk,
    height: 420,
    source: 'carousel/carousel_autoplay_example.dart',
    builder: CarouselAutoplayExample.new,
  ),
];
