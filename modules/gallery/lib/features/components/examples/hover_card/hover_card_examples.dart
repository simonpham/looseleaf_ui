import 'package:gallery/features/components/examples/hover_card/hover_card.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/hover-card/`.
const hoverCardExamples = <GalleryExample>[
  GalleryExample(
    title: 'Profile',
    description:
        'The shadcn demo as a polaroid: hover the link (or tab to it) and a small photo with handwriting on its margin lands next to it.',
    height: 340,
    source: 'hover_card/hover_card_profile_example.dart',
    builder: HoverCardProfileExample.new,
  ),
  GalleryExample(
    title: 'Taped, with a sticker',
    description:
        'The window holds any art: here a die-cut sticker, and the polaroid is taped down by a strip of washi across the top.',
    height: 340,
    source: 'hover_card/hover_card_taped_sticker_example.dart',
    builder: HoverCardTapedStickerExample.new,
  ),
  GalleryExample(
    title: 'Delays and sides',
    description:
        'openDelay and closeDelay tune how eager the card is (the default 700 / 300 ms is deliberate: a card that pops up on every pass of the pointer is noise). `side` and `align` place it: left and right cards start level with their link, so none rises above the page.',
    height: 320,
    source: 'hover_card/hover_card_delays_and_sides_example.dart',
    builder: HoverCardDelaysAndSidesExample.new,
  ),
  GalleryExample(
    title: 'Mentions in prose',
    description:
        'The real use: names in a paragraph that unfold into a card. Every mention is a real link that works without the card (touch, keyboard), and the card is a bonus for the pointer.',
    height: 340,
    source: 'hover_card/hover_card_mentions_example.dart',
    builder: HoverCardMentionsExample.new,
  ),
  GalleryExample(
    title: 'Plain content',
    description:
        "shadcn's `hover-card-demo`, written the way the original is: HoverCardContent with a width and ordinary children (an avatar, a name, a sentence and a date), none of the polaroid parts. The window is still a small photo-stock sheet, and it still only opens for a pointer.",
    height: 300,
    source: 'hover_card/hover_card_demo_example.dart',
    builder: HoverCardDemoExample.new,
  ),
];
