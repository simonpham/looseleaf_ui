import 'package:gallery/features/components/examples/typography/typography.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/typography/`.
const typographyExamples = <GalleryExample>[
  GalleryExample(
    title: 'The scale',
    description: 'Every part in one page: headings with hand rules, a lead line, body text, a list, a quotation, inline code and the small sizes.',
    layout: ExampleLayout.stack,
    source: 'typography/typography_scale_example.dart',
    builder: TypographyScaleExample.new,
  ),
  GalleryExample(
    title: 'Prose',
    description: "A reading log set in Prose: it gives the parts the notebook's type and spacing, with links, lists, code and quotations.",
    layout: ExampleLayout.stack,
    source: 'typography/typography_prose_example.dart',
    builder: TypographyProseExample.new,
  ),
  GalleryExample(
    title: 'An article on paper',
    description: 'The parts composed into a real page, with a mark or two from the marks family.',
    stage: ExampleStage.desk,
    source: 'typography/typography_article_example.dart',
    builder: TypographyArticleExample.new,
  ),
  GalleryExample(
    title: 'A plain table in prose',
    description: 'Official `typography-table`: a table inside Prose. The head is written in the script face over a felt rule and every row has a pencil line under it.',
    layout: ExampleLayout.stack,
    source: 'typography/typography_table_example.dart',
    builder: TypographyTableExample.new,
  ),
];
