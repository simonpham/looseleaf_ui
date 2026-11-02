import 'package:gallery/features/components/examples/resizable/resizable.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/resizable/`.
const resizableExamples = <GalleryExample>[
  GalleryExample(
    title: 'Panels',
    description:
        'Three panels and two seams, nested: a row with a column inside, on a slip of paper. The seam is stitched by hand; withHandle adds a paper tab with a grip. Drag it, or focus it and use the arrow keys (Home and End jump to the limits).',
    source: 'resizable/resizable_panels_example.dart',
    builder: ResizablePanelsExample.new,
  ),
  GalleryExample(
    title: 'Vertical, without a tab',
    description:
        'Axis.vertical stacks the panels and turns the seam; without withHandle the seam is only stitches. The middle panel has a minimum and a maximum, so the seams stop where the limits are.',
    source: 'resizable/resizable_vertical_example.dart',
    builder: ResizableVerticalExample.new,
  ),
  GalleryExample(
    title: 'Remembered layout',
    description:
        'onLayout reports the sizes as a seam moves; keep them anywhere and hand them back as defaultSize. Here they live in the example\'s state: resize, press Unmount and Remount, and the panels come back where you left them. Reset rebuilds the group at 35 / 65.',
    source: 'resizable/resizable_persisted_example.dart',
    builder: ResizablePersistedExample.new,
  ),
  GalleryExample(
    title: 'Mail layout',
    description:
        'A real screen: an inbox, a message and a details column. Pick a letter in the inbox and the other two follow it.',
    source: 'resizable/resizable_mail_example.dart',
    builder: ResizableMailExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official resizable-demo: a row of two panels, the second split into a column. The group sits on a slip of paper. Drag a seam, or focus it and use the arrow keys.',
    height: 300,
    source: 'resizable/resizable_demo_example.dart',
    builder: ResizableDemoExample.new,
  ),
  GalleryExample(
    title: 'Demo with handle',
    description:
        'Official resizable-demo-with-handle: the same layout with withHandle, which puts a small paper tab with a grip on each seam. The tab turns with the seam, so the column\'s seam is horizontal and its grip lies down.',
    height: 300,
    source: 'resizable/resizable_demo_with_handle_example.dart',
    builder: ResizableDemoWithHandleExample.new,
  ),
  GalleryExample(
    title: 'Vertical',
    description:
        'Official resizable-vertical: Axis.vertical stacks a header over the content with one horizontal seam. Arrow Up and Down move it from the keyboard.',
    height: 300,
    source: 'resizable/resizable_vertical_demo_example.dart',
    builder: ResizableVerticalDemoExample.new,
  ),
  GalleryExample(
    title: 'Handle',
    description:
        'Official resizable-handle: a narrow sidebar panel beside the content with the grip tab on the seam. This is the shape most apps start from; add minSize and maxSize on the panels to keep either side usable.',
    height: 300,
    source: 'resizable/resizable_handle_example.dart',
    builder: ResizableHandleExample.new,
  ),
];
