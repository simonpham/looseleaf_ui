import 'package:gallery/features/components/examples/kbd/kbd.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/kbd/`.
const kbdExamples = <GalleryExample>[
  GalleryExample(
    title: 'Keys and shortcuts',
    description:
        'Single keys inline, and KbdGroup for a combination. Each key is its own drawing, so no two caps are the same.',
    layout: ExampleLayout.stack,
    source: 'kbd/kbd_keys_and_groups_example.dart',
    builder: KbdKeysAndGroupsExample.new,
  ),
  GalleryExample(
    title: 'Press the keys',
    description:
        '`pressed` shows a key as held. Type on your keyboard: the caps you press sink onto their base (or press and hold one with the pointer).',
    layout: ExampleLayout.stack,
    source: 'kbd/kbd_press_the_keys_example.dart',
    builder: KbdPressTheKeysExample.new,
  ),
  GalleryExample(
    title: 'A shortcut sheet',
    description:
        'Kbd next to the things it triggers: a search field that says how to reach it, and a cheat sheet in a card. The muted keys stay quiet; the words next to them do the talking.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'kbd/kbd_shortcut_sheet_example.dart',
    builder: KbdShortcutSheetExample.new,
  ),
  GalleryExample(
    title: 'Modifier keys',
    description:
        'shadcn\'s `kbd-demo`: a KbdGroup of the four Mac modifiers, and a Ctrl + B written with a plain `+` between two keys. Each cap is drawn on its own, so no two are quite alike.',
    source: 'kbd/kbd_modifiers_example.dart',
    builder: KbdModifiersExample.new,
  ),
  GalleryExample(
    title: 'In a tooltip',
    description:
        'shadcn\'s `kbd-tooltip`: hover or focus a button to see its shortcut written on the tip. Inside a tooltip the keycaps take the tip\'s own ink. A `TooltipProvider` above the tooltips shares their delay, so the example brings its own.',
    height: 240,
    source: 'kbd/kbd_tooltip_example.dart',
    builder: KbdTooltipExample.new,
  ),
  GalleryExample(
    title: 'In an input group',
    description:
        'shadcn\'s `kbd-input-group`: a search box with the shortcut that focuses it written at the end. Two keycaps in one inline-end addon.',
    source: 'kbd/kbd_input_group_example.dart',
    builder: KbdInputGroupExample.new,
  ),
  GalleryExample(
    title: 'In a button',
    description:
        'shadcn\'s `kbd-button`: a keycap at the end of a button\'s label. The button takes a little less padding on that side so the cap sits close to the edge.',
    source: 'kbd/kbd_button_example.dart',
    builder: KbdButtonExample.new,
  ),
  GalleryExample(
    title: 'Group in a sentence',
    description:
        'shadcn\'s `kbd-group`: a KbdGroup sits inline in running text. Each Kbd here holds a whole chord ("Ctrl + B") as one cap; compare with the separate keys in the first example.',
    source: 'kbd/kbd_group_example.dart',
    builder: KbdGroupExample.new,
  ),
];
