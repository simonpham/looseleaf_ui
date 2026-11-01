import 'package:gallery/features/components/examples/label_tag/label_tag.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/label-tag/`.
const labelTagExamples = <GalleryExample>[
  GalleryExample(
    title: 'A hang tag',
    description: 'A card with clipped corners, a hole with its patch and brass eyelet, and a loop of natural twine. Everything drawn is one sheet: it turns and casts one shadow.',
    stage: ExampleStage.desk,
    source: 'label_tag/label_tag_hang_tag_example.dart',
    builder: LabelTagHangTagExample.new,
  ),
  GalleryExample(
    title: 'Shapes, stocks, string',
    description: 'Price tag, arched, and a luggage tag; kraft, white and colored card; natural or colored twine; a brass eyelet, a steel one, or a bare hole.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'label_tag/label_tag_shapes_example.dart',
    builder: LabelTagShapesExample.new,
  ),
  GalleryExample(
    title: 'Tags that link',
    description: 'onPressed makes the tag a link (or a button). It keeps its native focus and keyboard behavior and swings on its eyelet when you hover it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'label_tag/label_tag_link_tags_example.dart',
    builder: LabelTagLinkTagsExample.new,
  ),
  GalleryExample(
    title: 'A shelf of price tags',
    description: 'A real use: a product shelf on a kraft card, two tags to a row. Each tag is a labeled group with its price as text; the string hangs from the shelf edge.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'label_tag/label_tag_price_tags_example.dart',
    builder: LabelTagPriceTagsExample.new,
  ),
];
