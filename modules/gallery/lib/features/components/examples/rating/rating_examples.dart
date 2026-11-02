import 'package:gallery/features/components/examples/rating/rating.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/rating/`.
const ratingExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Hover to preview, click to choose. It is a radio group: Tab lands on the chosen glyph, then arrow keys, Home and End change the value.',
    layout: ExampleLayout.stack,
    source: 'rating/rating_default_example.dart',
    builder: RatingDefaultExample.new,
  ),
  GalleryExample(
    title: 'Glyphs, halves and sizes',
    description:
        'Stars, hearts and suns; `allowHalf` steps by 0.5 (two radios per glyph, one over each half); `max` sets how many; three sizes.',
    layout: ExampleLayout.stack,
    source: 'rating/rating_icons_and_halves_example.dart',
    builder: RatingIconsAndHalvesExample.new,
  ),
  GalleryExample(
    title: 'Review card',
    description:
        'A real-world use: a read-only display (an image with a text alternative, so no tab stop), a form control the post button checks, and a submit that reads its value.',
    stage: ExampleStage.desk,
    source: 'rating/rating_review_example.dart',
    builder: RatingReviewExample.new,
  ),
  GalleryExample(
    title: 'Survey rows',
    description:
        'Several ratings side by side with their own labels and a running summary. Each row is named with semanticLabel; the value text is your own.',
    layout: ExampleLayout.stack,
    source: 'rating/rating_survey_example.dart',
    builder: RatingSurveyExample.new,
  ),
];
