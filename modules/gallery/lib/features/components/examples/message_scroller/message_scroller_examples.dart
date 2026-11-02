import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/message-scroller/`.
const messageScrollerExamples = <GalleryExample>[
  GalleryExample(
    title: 'A transcript that opens at the end',
    description:
        'It opens on the newest message. Scroll up and the page fades at the top, the jump button wakes; press it and you glide back down.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'message_scroller/message_scroller_default_example.dart',
    builder: MessageScrollerDefaultExample.new,
  ),
  GalleryExample(
    title: 'Streaming and pinning',
    description:
        'Send a message: it is pinned near the top of the view and the reply grows beneath it (autoScroll). When the reply is taller than the room, the view follows its bottom, until you scroll up.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 460,
    source: 'message_scroller/message_scroller_streaming_example.dart',
    builder: MessageScrollerStreamingExample.new,
  ),
  GalleryExample(
    title: 'Earlier messages, and jumping to one',
    description:
        'Load older messages and the one you were reading stays exactly where it was (preserveScrollOnPrepend). scrollToMessage on the controller jumps to a message by id, and its visibility says which are in view.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 460,
    source: 'message_scroller/message_scroller_earlier_messages_example.dart',
    builder: MessageScrollerEarlierMessagesExample.new,
  ),
  GalleryExample(
    title: 'A whole chat',
    description:
        'Everything at once: a transcript that pins your message and follows the reply, streaming words that soak in, a tool-call note, a code slip with a diff, attachments, a typing pencil, day markers, and the composer with its paper plane and stop button.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 780,
    source: 'message_scroller/message_scroller_chat_app_example.dart',
    builder: MessageScrollerChatAppExample.new,
  ),
  GalleryExample(
    title: 'Scripted chat',
    description:
        'shadcn\'s `message-scroller-demo`: a whole chat around the scroller. Send plays the next line of a script; your message settles near the top (`scrollAnchor`), the reply streams in below it and the view follows it (`autoScroll`) until you scroll up. The original drives this with the AI SDK; here a few lines of state and a timer stand in for the model.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_demo_example.dart',
    builder: MessageScrollerDemoExample.new,
  ),
  GalleryExample(
    title: 'Scroll status',
    description:
        'shadcn\'s `message-scroller-scrollable`: the controller\'s `scrollable` says whether there is more to scroll toward the start and toward the end, so the footer can tell the reader where they can go. The transcript opens at the start (`defaultPosition: MessageScrollerPosition.start`).',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 640,
    source: 'message_scroller/message_scroller_scrollable_example.dart',
    builder: MessageScrollerScrollableExample.new,
  ),
  GalleryExample(
    title: 'Transcript outline',
    description:
        'shadcn\'s `message-scroller-visibility`: the controller\'s `visibility` reports the anchor (the last user turn scrolled past the top) and `scrollToMessage` jumps to a turn. The ticks in the header are the outline; open them (click, Enter or Space) for the list. The original opens it on hover beside the card, which a keyboard cannot; a popover can be tabbed into.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_visibility_example.dart',
    builder: MessageScrollerVisibilityExample.new,
  ),
  GalleryExample(
    title: 'Commands',
    description:
        'shadcn\'s `message-scroller-commands`: `MessageScrollerProvider.of` gives `scrollToMessage`, `scrollToStart` and `scrollToEnd` to anything inside the provider, so a menu in the card header can drive the transcript. Choose a question and it slides to the top of the view.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_commands_example.dart',
    builder: MessageScrollerCommandsExample.new,
  ),
  GalleryExample(
    title: 'Opening position',
    description:
        'shadcn\'s `message-scroller-opening-position`: where a saved transcript opens. `start` shows the first message, `end` the newest, and `last-anchor` puts the last message you sent at the top, which is usually where you stopped. The provider is keyed on the choice so it opens afresh each time. (The original uses Tabs with no panels; a toggle group is the right control for a choice with no content behind it.)',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 640,
    source: 'message_scroller/message_scroller_opening_position_example.dart',
    builder: MessageScrollerOpeningPositionExample.new,
  ),
  GalleryExample(
    title: 'Anchoring turns',
    description:
        'shadcn\'s `message-scroller-anchoring`: `scrollAnchor` decides which message settles near the top when it arrives. Pick User or Assistant, send the scripted turns, and watch where each new one lands. Changing the role starts the transcript over.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_anchoring_example.dart',
    builder: MessageScrollerAnchoringExample.new,
  ),
  GalleryExample(
    title: 'Keeping context visible',
    description:
        'shadcn\'s `message-scroller-previous-context`: `previousItemPeek` is how much of the previous reply stays in sight above a new anchor, and `scrollMargin` the space kept above it. Drag the slider, send the next line, and see how much of the last answer is left above your message.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_previous_context_example.dart',
    builder: MessageScrollerPreviousContextExample.new,
  ),
  GalleryExample(
    title: 'Group chat',
    description:
        'shadcn\'s `message-scroller-group-chat`: several speakers and an assistant, and a Marker that is itself the anchor. When Rocky joins, the marker (`scrollAnchor` on its MessageScrollerItem) settles near the top and his reply arrives beneath it. Your own lines are on the right, the assistant is unframed, the others are tinted.',
    layout: ExampleLayout.center,
    stage: ExampleStage.desk,
    height: 680,
    source: 'message_scroller/message_scroller_group_chat_example.dart',
    builder: MessageScrollerGroupChatExample.new,
  ),
];
