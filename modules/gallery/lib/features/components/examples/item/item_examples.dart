import 'package:gallery/features/components/examples/item/item.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/item/`.
const itemExamples = <GalleryExample>[
  GalleryExample(
    title: 'Variants and sizes',
    description:
        'Bare, outlined in ruled pencil, and washed in paper-shade. The small size trims the padding.',
    layout: ExampleLayout.stack,
    source: 'item/item_variants_example.dart',
    builder: ItemVariantsExample.new,
  ),
  GalleryExample(
    title: 'A ruled list of links',
    description:
        'ruled puts a blue pencil line under every row, so the rules always match the rows. Pressable rows (onPressed) light up under a highlighter swipe when you point at them, and take the focus ring from the keyboard.',
    layout: ExampleLayout.stack,
    source: 'item/item_ruled_list_and_links_example.dart',
    builder: ItemRuledListAndLinksExample.new,
  ),
  GalleryExample(
    title: 'An inbox',
    description:
        'Rows doing real work in a card: photographs that lie a little crooked, a status badge in the title, actions on the right, and a header and footer on the row that needs them.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'item/item_inbox_example.dart',
    builder: ItemInboxExample.new,
  ),
  GalleryExample(
    title: 'Basic and link',
    description:
        'shadcn\'s item-demo: an outlined row with a title, a description and a button, and a small pressable row with a verified badge in front and a chevron behind.',
    source: 'item/item_demo_example.dart',
    builder: ItemDemoExample.new,
  ),
  GalleryExample(
    title: 'Sizes',
    description:
        'shadcn\'s item-size (its source is the same two rows as the demo): default gives a row 16 px of padding, sm trims it. Here the same content is set at both sizes, one under the other, so the difference is easy to see.',
    source: 'item/item_size_example.dart',
    builder: ItemSizeExample.new,
  ),
  GalleryExample(
    title: 'Variants',
    description:
        'shadcn\'s item-variant: default is bare, outline has a ruled pencil line round it, muted is a wash of paper-shade. The same three words as upstream.',
    source: 'item/item_variant_example.dart',
    builder: ItemVariantExample.new,
  ),
  GalleryExample(
    title: 'Icon',
    description:
        'shadcn\'s item-icon: ItemMediaVariant.icon sets a glyph in a square of its own at the start of the row.',
    source: 'item/item_icon_example.dart',
    builder: ItemIconExample.new,
  ),
  GalleryExample(
    title: 'Image',
    description:
        'shadcn\'s item-image: a list of tracks, each a pressable row with a small picture (ItemMediaVariant.image), a title with the album in muted type, the artist below and the running time at the far end. The pictures are doodles, pasted in a little crooked.',
    source: 'item/item_image_example.dart',
    builder: ItemImageExample.new,
  ),
  GalleryExample(
    title: 'Avatar',
    description:
        'shadcn\'s item-avatar: a single face with an invite button, and a stack of faces beside an invite text button. Faces are initials on marker; the photographs of the original are left out.',
    source: 'item/item_avatar_example.dart',
    builder: ItemAvatarExample.new,
  ),
  GalleryExample(
    title: 'Group with separators',
    description:
        'shadcn\'s item-group: ItemGroup makes the rows a list and ItemSeparator draws the pencil line between them (the last row has none).',
    source: 'item/item_group_example.dart',
    builder: ItemGroupExample.new,
  ),
  GalleryExample(
    title: 'Header',
    description:
        'shadcn\'s item-header: ItemHeader takes the first, full-width line of a row, so a picture sits above the words. Three cards in a grid; the photographs of the original are doodles here.',
    source: 'item/item_header_example.dart',
    builder: ItemHeaderExample.new,
  ),
  GalleryExample(
    title: 'In a dropdown',
    description:
        'shadcn\'s item-dropdown: each menu row is an Item, so a menu can show a face, a name and a line of detail. Arrow keys and typeahead still belong to the menu.',
    height: 340,
    source: 'item/item_dropdown_example.dart',
    builder: ItemDropdownExample.new,
  ),
  GalleryExample(
    title: 'Links',
    description:
        'shadcn\'s item-link: onPressed makes the whole row a link. The row gets the highlighter swipe on hover and a focus outline.',
    source: 'item/item_link_example.dart',
    builder: ItemLinkExample.new,
  ),
];
