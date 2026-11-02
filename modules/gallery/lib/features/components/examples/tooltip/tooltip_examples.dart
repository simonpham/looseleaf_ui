import 'package:gallery/features/components/examples/tooltip/tooltip.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/tooltip/`.
const tooltipExamples = <GalleryExample>[
  GalleryExample(
    title: 'Icon toolbar',
    description:
        'The everyday use: names for icon buttons. One provider holds the delay (a calm 300 ms), and once one note is open the next opens at once as you sweep along the row. Each button still has its own semanticLabel.',
    height: 220,
    source: 'tooltip/tooltip_icon_toolbar_example.dart',
    builder: TooltipIconToolbarExample.new,
  ),
  GalleryExample(
    title: 'Sides and notes',
    description:
        'The arrow follows whichever side the note opens on (it flips near the edge of the screen). Any stock makes a note: sticky pads in four colors, or a plain slip.',
    height: 300,
    source: 'tooltip/tooltip_sides_and_notes_example.dart',
    builder: TooltipSidesAndNotesExample.new,
  ),
  GalleryExample(
    title: 'Delays and shortcut hints',
    description:
        "A per-tooltip delay overrides the provider's: instant for a quick label, patient for an explanation. A shortcut hint sits in the note in the mono font.",
    height: 240,
    source: 'tooltip/tooltip_shortcut_hint_example.dart',
    builder: TooltipShortcutHintExample.new,
  ),
  GalleryExample(
    title: 'Why is it disabled?',
    description:
        'A disabled button takes no focus, so it cannot show a tooltip on its own. Wrap it in a Focus: keyboard and mouse users see the reason, and the trigger carries it as its tooltip for screen readers.',
    height: 240,
    source: 'tooltip/tooltip_disabled_reason_example.dart',
    builder: TooltipDisabledReasonExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `tooltip-demo`: a Hover button with the note "Add to library". The note is a sticky with a felt-tip arrow, opened by hover and keyboard focus. A TooltipProvider above sets the delay.',
    height: 200,
    source: 'tooltip/tooltip_demo_example.dart',
    builder: TooltipDemoExample.new,
  ),
];
