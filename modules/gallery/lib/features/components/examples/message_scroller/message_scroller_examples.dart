import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/message-scroller/`.
const messageScrollerExamples = <GalleryExample>[
  GalleryExample(
    title: 'A transcript that opens at the end',
    description: 'It opens on the newest message. Scroll up and the page fades at the top, the jump button wakes; press it and you glide back down.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'message_scroller/message_scroller_default_example.dart',
    builder: MessageScrollerDefaultExample.new,
  ),
  GalleryExample(
    title: 'Streaming and pinning',
    description: 'Send a message: it is pinned near the top of the view and the reply grows beneath it (autoScroll). When the reply is taller than the room, the view follows its bottom, until you scroll up.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 460,
    source: 'message_scroller/message_scroller_streaming_example.dart',
    builder: MessageScrollerStreamingExample.new,
  ),
  GalleryExample(
    title: 'Earlier messages, and jumping to one',
    description: 'Load older messages and the one you were reading stays exactly where it was (preserveScrollOnPrepend). scrollToMessage on the controller jumps to a message by id, and its visibility says which are in view.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 460,
    source: 'message_scroller/message_scroller_earlier_messages_example.dart',
    builder: MessageScrollerEarlierMessagesExample.new,
  ),
  GalleryExample(
    title: 'A whole chat',
    description: 'Everything at once: a transcript that pins your message and follows the reply, streaming words that soak in, a tool-call note, a code slip with a diff, attachments, a typing pencil, day markers, and the composer with its paper plane and stop button.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 780,
    source: 'message_scroller/message_scroller_chat_app_example.dart',
    builder: MessageScrollerChatAppExample.new,
  ),
];
