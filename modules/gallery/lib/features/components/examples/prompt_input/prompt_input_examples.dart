import 'package:gallery/features/components/examples/prompt_input/prompt_input.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/prompt-input/`.
const promptInputExamples = <GalleryExample>[
  GalleryExample(
    title: 'The composer',
    description:
        'Type, press Enter and the paper plane flies. Shift+Enter breaks the line; the box grows with the text up to eight rows. The send button is pencilled in until there is something to send.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'prompt_input/prompt_input_composer_example.dart',
    builder: PromptInputComposerExample.new,
  ),
  GalleryExample(
    title: 'While a reply streams',
    description:
        'With status streaming the send button is a stop button and sending waits; you can keep typing the next message. lockWhileStreaming makes the text read-only instead.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'prompt_input/prompt_input_streaming_example.dart',
    builder: PromptInputStreamingExample.new,
  ),
  GalleryExample(
    title: 'Slash commands and @mentions',
    description:
        'The composer knows no data. triggers says which characters open a list, PromptInputModel.of(context).trigger gives the word being typed, and you render the choices. Arrows move, Enter or Tab pick, Escape closes.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'prompt_input/prompt_input_commands_and_mentions_example.dart',
    builder: PromptInputCommandsAndMentionsExample.new,
  ),
  GalleryExample(
    title: 'With attachments',
    description:
        'Chips in the row above the text, a file button in the tools, a send that also works with no words when allowEmpty is set. Pick a file to add a chip; the remove button takes it away again.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'prompt_input/prompt_input_attachments_example.dart',
    builder: PromptInputAttachmentsExample.new,
  ),
];
