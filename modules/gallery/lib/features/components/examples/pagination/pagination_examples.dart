import 'package:gallery/features/components/examples/pagination/pagination.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/pagination/`.
const paginationExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'The shadcn demo: Previous, three numbers with the second current, an ellipsis, Next. The current page is a block of highlighter; point at another and it wears the wash.',
    source: 'pagination/pagination_default_example.dart',
    builder: PaginationDefaultExample.new,
  ),
  GalleryExample(
    title: 'Controlled, with gaps',
    description: 'Nine pages with the classic windowing: the first and last always show, the current page has a neighbor on each side, the rest fold into ellipses. Previous is inert on page 1 and Next on page 9.',
    source: 'pagination/pagination_controlled_example.dart',
    builder: PaginationControlledExample.new,
  ),
  GalleryExample(
    title: 'Simple pager',
    description: 'Previous, a line of text, Next: for a feed or a list you page through. Sizes are Button sizes; here the arrows are square icon buttons with a label of their own, and a load-more link uses the large size.',
    source: 'pagination/pagination_simple_example.dart',
    builder: PaginationSimpleExample.new,
  ),
  GalleryExample(
    title: 'Table footer (composed)',
    description: 'A real use: twenty-three notebooks, five to a page. The range under the table and the current number follow the page.',
    height: 440,
    source: 'pagination/pagination_table_footer_example.dart',
    builder: PaginationTableFooterExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `pagination-demo`, part for part. The current page is a block of highlighter; the others wear it when pointed at.',
    source: 'pagination/pagination_demo_example.dart',
    builder: PaginationDemoExample.new,
  ),
];
