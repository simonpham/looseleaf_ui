import 'package:gallery/features/components/examples/toggle/toggle.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/toggle/`.
const toggleExamples = <GalleryExample>[
  GalleryExample(
    title: 'Variants',
    description:
        'Default is a whisper of pencil that becomes a highlighted, boxed button when it is on. Outline keeps its ink box the whole time. Icon-only toggles need a semanticLabel.',
    layout: ExampleLayout.stack,
    source: 'toggle/toggle_variants_example.dart',
    builder: ToggleVariantsExample.new,
  ),
  GalleryExample(
    title: 'Sizes, tones and disabled',
    description:
        'Three heights, the terracotta marker for a louder switch, and disabled toggles: a dashed pencil box, and a pale wash if it is on.',
    layout: ExampleLayout.stack,
    source: 'toggle/toggle_sizes_and_states_example.dart',
    builder: ToggleSizesAndStatesExample.new,
  ),
  GalleryExample(
    title: 'A follow button',
    description:
        'A controlled toggle: the state lives in your component, the label says what pressing does, and a status line says what happened, so nothing depends on the highlighter.',
    layout: ExampleLayout.stack,
    source: 'toggle/toggle_follow_button_example.dart',
    builder: ToggleFollowButtonExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `toggle-demo`: a small outline toggle with a bookmark and a word. shadcn fills the bookmark blue when it is on; this one keeps its highlighter body and writes the bookmark in blue felt tip, because a drawn line has no fill to change. Space or Enter toggles it.',
    source: 'toggle/toggle_demo_example.dart',
    builder: ToggleDemoExample.new,
  ),
  GalleryExample(
    title: 'Disabled',
    description:
        'Official `toggle-disabled`: an icon-only toggle with `disabled`. It is drawn as a dashed pencil-gray box and takes no pointer or keyboard. (The original\'s label says "italic" on an underline; this one says what it shows.)',
    source: 'toggle/toggle_disabled_example.dart',
    builder: ToggleDisabledExample.new,
  ),
  GalleryExample(
    title: 'Large',
    description:
        'Official `toggle-lg`: `size: ToggleSize.lg`, 40 px tall (36 in compact density, 32 in calm), for touch-first toolbars.',
    source: 'toggle/toggle_lg_example.dart',
    builder: ToggleLgExample.new,
  ),
  GalleryExample(
    title: 'Outline',
    description:
        'Official `toggle-outline`: `variant: ToggleVariant.outline` keeps a felt-tip box around the toggle whether it is on or off; the default variant is only a whisper of pencil until it is pressed.',
    source: 'toggle/toggle_outline_example.dart',
    builder: ToggleOutlineExample.new,
  ),
  GalleryExample(
    title: 'Small',
    description:
        'Official `toggle-sm`: `size: ToggleSize.sm`, 32 px tall, for dense toolbars.',
    source: 'toggle/toggle_sm_example.dart',
    builder: ToggleSmExample.new,
  ),
  GalleryExample(
    title: 'With text',
    description:
        'Official `toggle-with-text`: an icon and a word. With a visible word the toggle needs no `semanticLabel`, and the highlighter body stretches to fit both.',
    source: 'toggle/toggle_with_text_example.dart',
    builder: ToggleWithTextExample.new,
  ),
];
