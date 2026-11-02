import 'package:gallery/features/components/examples/clipboard/clipboard.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/clipboard/`.
const clipboardExamples = <GalleryExample>[
  GalleryExample(
    title: 'A clipboard',
    description:
        'Hardboard with the grain of its fiber, a chrome spring clip over the paper, and a checklist on the ruled sheet (each row is one 28 px line).',
    stage: ExampleStage.desk,
    source: 'clipboard/clipboard_default_example.dart',
    builder: ClipboardDefaultExample.new,
  ),
  GalleryExample(
    title: 'Hardboard and plastic',
    description:
        'The same board in hardboard and in colored plastic. The paper stays cream, so nothing on it changes contrast.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'clipboard/clipboard_tones_example.dart',
    builder: ClipboardTonesExample.new,
  ),
  GalleryExample(
    title: 'Graph paper and tape',
    description:
        'The paper is a Paper: graph rules, a strip of tape across a corner, a small extra note taped on top.',
    stage: ExampleStage.desk,
    source: 'clipboard/clipboard_taped_graph_example.dart',
    builder: ClipboardTapedGraphExample.new,
  ),
  GalleryExample(
    title: 'A sign-in sheet',
    description:
        'A real form on the paper: a name, a visit, a button, and the visitors so far listed as they sign. The paper is labelled for screen readers.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 440,
    source: 'clipboard/clipboard_sign_in_sheet_example.dart',
    builder: ClipboardSignInSheetExample.new,
  ),
];
