import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/marker/`.
const markerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Day separators',
    description:
        'A ruled pencil line on each side of the day, written in the script font. The lines run level and stop just short of the words.',
    layout: ExampleLayout.stack,
    source: 'marker/marker_separators_example.dart',
    builder: MarkerSeparatorsExample.new,
  ),
  GalleryExample(
    title: 'Where you stopped reading',
    description:
        'MarkerTone.fresh pulls the lines in red pencil and lays a highlighter swipe under the words, with a red asterisk in the margin. As a button it jumps to the first unread message.',
    layout: ExampleLayout.stack,
    source: 'marker/marker_unread_example.dart',
    builder: MarkerUnreadExample.new,
  ),
  GalleryExample(
    title: 'Borders and events',
    description:
        'A border marker heads a section with one line under it (pencil or a red wavy one). The default variant is small print with an icon: someone joined, a call started.',
    layout: ExampleLayout.stack,
    source: 'marker/marker_borders_and_events_example.dart',
    builder: MarkerBordersAndEventsExample.new,
  ),
  GalleryExample(
    title: 'In a conversation',
    description:
        "shadcn's `marker-demo`: a note with an icon, a running status with a spinner (a live region, pulsing), a labeled separator and another note.",
    source: 'marker/marker_demo_example.dart',
    builder: MarkerDemoExample.new,
  ),
  GalleryExample(
    title: 'Variants',
    description:
        "shadcn's `marker-variants`: `regular` is a line of small print, `separator` writes its words between two pencil lines, `border` draws one line under the row.",
    source: 'marker/marker_variants_example.dart',
    builder: MarkerVariantsExample.new,
  ),
  GalleryExample(
    title: 'Status',
    description:
        "shadcn's `marker-status`: a live region around a marker means a screen reader hears \"Compacting conversation\" when it appears. A Spinner in MarkerIcon shows that something is running.",
    source: 'marker/marker_status_example.dart',
    builder: MarkerStatusExample.new,
  ),
  GalleryExample(
    title: 'Shimmer',
    description:
        "shadcn's `marker-shimmer`: a status line that breathes while it is streaming. The pulse holds still for readers who ask for less motion.",
    source: 'marker/marker_shimmer_example.dart',
    builder: MarkerShimmerExample.new,
  ),
  GalleryExample(
    title: 'Separator',
    description:
        "shadcn's `marker-separator`: a labeled divider for a date or a turn of the conversation. The words are ordinary content, so they are read out.",
    source: 'marker/marker_separator_example.dart',
    builder: MarkerSeparatorExample.new,
  ),
  GalleryExample(
    title: 'Border',
    description:
        "shadcn's `marker-border`: a row with an icon that keeps the default alignment and closes with a line under it, to set it off from the row below.",
    source: 'marker/marker_border_example.dart',
    builder: MarkerBorderExample.new,
  ),
  GalleryExample(
    title: 'With icon',
    description:
        "shadcn's `marker-icon`: MarkerIcon in front of the words in a plain marker, and in a separator (the icon sits in the middle with the lines on both sides). `book-open-check` is not drawn yet, so the last one uses `book-open`.",
    source: 'marker/marker_icon_example.dart',
    builder: MarkerIconExample.new,
  ),
  GalleryExample(
    title: 'Links and buttons',
    description:
        "shadcn's `marker-link-button`: onPressed makes the marker a real button, so it is focusable and announced as one. The second says so with a toast. `rotate-ccw` is not drawn yet; the revert button wears `undo-2`.",
    source: 'marker/marker_link_button_example.dart',
    builder: MarkerLinkButtonExample.new,
  ),
];
