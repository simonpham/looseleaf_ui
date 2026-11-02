import 'package:gallery/features/components/examples/table/table.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/table/`.
const tableExamples = <GalleryExample>[
  GalleryExample(
    title: 'Invoices',
    description: 'The whole family: a header with a double rule, rows ruled by hand in pencil, a footer with its own double rule and a caption written underneath. Hover a row to see the swipe.',
    layout: ExampleLayout.stack,
    source: 'table/table_invoices_example.dart',
    builder: TableInvoicesExample.new,
  ),
  GalleryExample(
    title: 'Data table',
    description: 'Sorting, selection and pagination with plain state and no extra dependency. A selected row is a highlighter swipe (`selected: true`), the sorted column says so with `sort` and an arrow, and the header checkbox goes half-ticked when only some rows are chosen. Colored pencil text is 4.7:1 on paper but about 4:1 on the full swipe, so a chosen row writes its status in ink.',
    layout: ExampleLayout.stack,
    source: 'table/table_data_table_example.dart',
    builder: TableDataTableExample.new,
  ),
  GalleryExample(
    title: 'Scrolling body',
    description: 'A table in a scroller with a fixed height: the body scrolls inside the card.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'table/table_sticky_header_example.dart',
    builder: TableStickyHeaderExample.new,
  ),
  GalleryExample(
    title: 'Team billing',
    description: 'A real screen: a card holding a table of people with faces, roles, a presence dot and what each seat costs, a highlighted row for the person you are looking at, a row button, and a footer with the total.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'table/table_team_example.dart',
    builder: TableTeamExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `table-demo`: seven invoices with a caption, a header, a footer total and a right-aligned amount column. The ruling is pencil: a double rule under the header, a hand-pulled line under each row, the accountant\'s pair above the total.',
    source: 'table/table_demo_example.dart',
    builder: TableDemoExample.new,
  ),
  GalleryExample(
    title: 'Data table demo',
    description: 'Official `data-table-demo`, rebuilt with plain state: filter the emails, sort the Email column, hide columns from the Columns menu, tick rows (the header box goes half-ticked when only some of a page are), and page with Previous and Next. Chosen rows are a highlighter swipe. The original\'s five rows fit on one page, so this one has twelve at five a page.',
    height: 460,
    source: 'table/table_data_table_demo_example.dart',
    builder: TableDataTableDemoExample.new,
  ),
];
