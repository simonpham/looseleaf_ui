import 'package:gallery/features/components/examples/code_block/code_block.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/code-block/`.
const codeBlockExamples = <GalleryExample>[
  GalleryExample(
    title: 'A typed slip',
    description: 'Pass `code`, a `filename` and a language: the header, the copy button and the lines come with it. Keywords are typed in red, functions struck twice, strings underscored.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'code_block/code_block_default_example.dart',
    builder: CodeBlockDefaultExample.new,
  ),
  GalleryExample(
    title: 'A diff',
    description: 'Removed lines are struck through in red pencil, added lines are ticked in green, and the header counts them. Copy puts the result on the clipboard.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'code_block/code_block_diff_example.dart',
    builder: CodeBlockDiffExample.new,
  ),
  GalleryExample(
    title: 'css, json and bash',
    description: 'The small lexer knows tsx, ts, jsx, js, css, json, bash, dart and yaml. The language comes from the file name when you do not say. Long lines wrap with `wrap`.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'code_block/code_block_languages_example.dart',
    builder: CodeBlockLanguagesExample.new,
  ),
  GalleryExample(
    title: 'In a reply',
    description: 'A code slip inside a message: it takes the width of the column and scrolls sideways when a line is long.',
    layout: ExampleLayout.stack,
    source: 'code_block/code_block_in_a_chat_example.dart',
    builder: CodeBlockInAChatExample.new,
  ),
];
