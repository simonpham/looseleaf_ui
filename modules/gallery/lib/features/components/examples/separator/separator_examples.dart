import 'package:gallery/features/components/examples/separator/separator.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/separator/`.
const separatorExamples = <GalleryExample>[
  GalleryExample(
    title: 'Seven ways to draw a line',
    description: 'Pencil is the default. The others are for when a divider should say something: ledger dashes, a squiggle, dots, kraft tape, a running stitch, a torn edge.',
    layout: ExampleLayout.stack,
    source: 'separator/separator_styles_example.dart',
    builder: SeparatorStylesExample.new,
  ),
  GalleryExample(
    title: 'Or continue with',
    description: 'Children turn the separator into a labeled divider: two rules and a word. Here it splits a sign-in card in two, the way every sign-in card does.',
    layout: ExampleLayout.stack,
    source: 'separator/separator_with_a_label_example.dart',
    builder: SeparatorWithALabelExample.new,
  ),
  GalleryExample(
    title: 'Vertical rules',
    description: 'In a flex row give the separator a height (a SizedBox, or a stretched cross axis). Each vertical rule is its own drawing, so no two are quite alike.',
    layout: ExampleLayout.stack,
    source: 'separator/separator_vertical_example.dart',
    builder: SeparatorVerticalExample.new,
  ),
  GalleryExample(
    title: 'Between the sections of a page',
    description: 'A torn strip where a page changes subject, a stitch where two things are joined, tape for the fold. Real headings and paragraphs stay real; the dividers are decoration.',
    layout: ExampleLayout.stack,
    source: 'separator/separator_page_sections_example.dart',
    builder: SeparatorPageSectionsExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `separator-demo`: a heading and blurb, a horizontal rule, then three links divided by vertical rules. Both rules are pencil pulls; the vertical ones fill the height of their row.',
    source: 'separator/separator_demo_example.dart',
    builder: SeparatorDemoExample.new,
  ),
];
