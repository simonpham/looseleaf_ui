import 'package:gallery/features/components/examples/message/message.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/message/`.
const messageExamples = <GalleryExample>[
  GalleryExample(
    title: 'A thread',
    description:
        'Two speakers. The footer of the first message rides above the avatar, so the avatar keeps standing beside the last bubble.',
    layout: ExampleLayout.stack,
    source: 'message/message_thread_example.dart',
    builder: MessageThreadExample.new,
  ),
  GalleryExample(
    title: 'Streaming text',
    description:
        'MessageText keeps the words already on the page and soaks each new word in as it arrives: dark and blurred at first, then dry. A felt-tip caret rides after the last word.',
    layout: ExampleLayout.stack,
    source: 'message/message_streaming_example.dart',
    builder: MessageStreamingExample.new,
  ),
  GalleryExample(
    title: 'Names, times and receipts',
    description:
        'Header and footer are quiet hand notes. A reaction chip and a tick make a message look lived in.',
    layout: ExampleLayout.stack,
    source: 'message/message_header_footer_example.dart',
    builder: MessageHeaderFooterExample.new,
  ),
  GalleryExample(
    title: 'In your own hand',
    description:
        '`pen: BubblePen.you` sets a bubble in blue felt and the script face. MessageText keeps its words plain inline text with a baseline offset and a lighter ink, so the tall last letters of a script face (d, l, e, !) are whole.',
    layout: ExampleLayout.stack,
    source: 'message/message_your_own_hand_example.dart',
    builder: MessageYourOwnHandExample.new,
  ),
  GalleryExample(
    title: 'A Friday deploy',
    description:
        'shadcn\'s `message-demo`: two speakers, avatars on the side of their message, a delivery note under the last of mine, a pair of muted bubbles with a reaction chip, and a typing marker to end. The photo avatars of the original are initials on marker here.',
    source: 'message/message_demo_example.dart',
    builder: MessageDemoExample.new,
  ),
  GalleryExample(
    title: 'Avatar',
    description:
        'shadcn\'s `message-avatar`: MessageAvatar sits at the bottom of the row, on the side the message is aligned to (`align: ChatAlign.end` moves it to the right). In a BubbleGroup the avatar stays beside the last bubble.',
    source: 'message/message_avatar_example.dart',
    builder: MessageAvatarExample.new,
  ),
  GalleryExample(
    title: 'Group',
    description:
        'shadcn\'s `message-group`: consecutive messages from one sender. The earlier ones carry an empty MessageAvatar to hold the column, so the words line up and the face appears once, on the last.',
    source: 'message/message_group_example.dart',
    builder: MessageGroupExample.new,
  ),
  GalleryExample(
    title: 'Header and footer',
    description:
        'shadcn\'s `message-header-footer`: MessageHeader names the sender above the bubble, MessageFooter holds a receipt below it. The header stays at the start whatever the alignment; the footer follows the message.',
    source: 'message/message_header_footer_official_example.dart',
    builder: MessageHeaderFooterOfficialExample.new,
  ),
  GalleryExample(
    title: 'Actions',
    description:
        'shadcn\'s `message-actions`: icon buttons in MessageFooter (copy, like, dislike), each with a `semanticLabel`, and a failed send with a retry. The thumbs are not drawn yet, so like and dislike wear a tick and a cross-out.',
    source: 'message/message_actions_example.dart',
    builder: MessageActionsExample.new,
  ),
  GalleryExample(
    title: 'Attachment',
    description:
        'shadcn\'s `message-attachment`: an image attachment above the bubble that sent it (a polaroid under tape), and a PDF the reply hands back (a slip with a paper clip and a download button). The photograph is a sticker so the page needs no network.',
    source: 'message/message_attachment_example.dart',
    builder: MessageAttachmentExample.new,
  ),
  GalleryExample(
    title: 'Rich replies',
    description:
        'shadcn\'s `message-markdown`: the user\'s message stays plain text in a bubble; the assistant\'s reply goes in a `ghost` bubble, which has no frame, so rendered markdown (a list, bold, inline code) reads as a page. shadcn\'s docs render it with their own Markdown component, which is not part of the registry; the markup below is what such a renderer produces.',
    source: 'message/message_markdown_example.dart',
    builder: MessageMarkdownExample.new,
  ),
];
