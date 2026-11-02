# Porting a component

How to turn one upstream component (`.upstream/looseleaf/src/components/ui/<name>.tsx`) into a Flutter widget. `Button` and `Checkbox` are the reference ports: read them first.

## Folder layout

```
lib/src/components/
├── components.dart          # barrel: one export per component folder
├── foundation/              # shared pieces (below)
└── <name>/
    ├── <name>.dart          # barrel
    ├── <name>_widget.dart   # the widget, named like the shadcn part (Button, Checkbox)
    └── <name>_metrics.dart  # optional: sizes and colors read from the CSS
```

- One public widget per file. A component with several parts (`Card`, `CardHeader`, …) gets one file per part, all in the same folder.
- Inside the folder, import siblings through the folder barrel.
- Add the folder barrel to `components.dart` (the commit script's `--barrel` does it, see below).

## Names that differ from shadcn

Part names follow shadcn/ui, except where one would clash with a name a Flutter app imports anyway (`package:flutter/widgets.dart`, `package:flutter/services.dart`, `dart:core`) or with the engine `looseleaf_ui` re-exports. Those get an `Ink` (or `Paper`) prefix; their other parts keep shadcn's names.

| shadcn / Looseleaf | Looseleaf UI | Clashes with |
|--------------------|--------------|--------------|
| `Icon` | `InkIcon` | widgets `Icon` |
| `Table`, `TableRow`, `TableCell` | `InkTable`, `InkTableRow`, `InkTableCell` | widgets `Table`, `TableRow`, `TableCell` |
| `Page` | `PaperPage` | widgets `Page` |
| `Form`, `FormField` | `InkForm`, `InkFormField` | widgets `Form`, `FormField` |
| `RadioGroup`, `RadioGroupItem` | `InkRadioGroup`, `InkRadioGroupItem` | widgets `RadioGroup` |
| `Clipboard` | `InkClipboard` | services `Clipboard` |
| `Item` | `InkItem` | the engine's `Item` |
| typography `List` | `TypographyList` | dart:core `List` |

Check a new component with `tools/names/check_clashes.sh`: it lists every public name that is ambiguous next to those imports.

## Foundation (`components/foundation/`)

| Piece | What it does |
|-------|--------------|
| `InkInteraction` | Turns input into `InkState`s: `hovered`, `pressed`, `focused` (keyboard only, like `:focus-visible`), `disabled`, plus the component's own `states` (`checked`, `invalid`, `open`, …). Calls `onActivate` on tap and on its keys. Owns focus, cursor, hit slop and the component's `semantics` node (never wrap it in a `Semantics`: the outer box would swallow taps in the slop). |
| `InkActivation` | Which keys activate: `button` (Enter, Space) or `toggle` (Space only, Radix toggles). |
| `InkSeed` | State mixin: `inkSeed(widget.seed)` returns the `seed` prop or a per-State id, like upstream `useInkSeed`. |
| `ByDensity<T>` | A value per density: upstream's `h-9 compact:h-8 calm:h-7`. |
| `InkContent` | Styles a content slot: text style plus `IconTheme` size and color (upstream `IconSizeContext`, `[&_svg]:size-4`). |
| `InkHitArea` | Grows the hit area without moving layout (upstream `after:-inset-*`). Keep it outermost: any box around it (`Semantics`, `MouseRegion`) rejects taps outside its own size first. |
| `InkOverflowScroll` | A row that scrolls sideways once it is wider than its parent (tabs, toggle groups), clipping only along the row so ink bleeds above and below, and keeping the focused item in view. |

Theme pieces you will use: `LooseleafTheme.of(context)` (colors, typography, density), `theme.typography.face(KevinSansFace.hand, cssSize:, cssLineHeight:, fontWeight:)`, `theme.typography.label()`, `Spacing`, `InkMotion` (durations, curves, `InkMotion.of(context, duration)` for reduced motion).

## Paper surfaces

Anything that sits on a sheet (card, dialog, sheet, drawer, popover, menus, select, command, sidebar, field, item) is a `Paper` with its own stock and padding. Never paint a paper background by hand.

| Piece | What it does |
|-------|--------------|
| `Paper` | A sheet with `child` on it: `stock`, `edge`, `tilt` / `tiltDegrees`, `rules`, `tape`, `fastener`, `shadow` (`PaperShadow.stock`, `.none`, `.lift`, …), `curl`, `padding`, `decor` (a drawn layer over the paper, like a page's holes). Sizes to `child`. Calm cuts edges, flattens tilt, hides tape and fasteners. |
| `PaperBackground` | Just the sheet (face, tooth, shadow, rules, tilt), filling its parent. Use it in a `Stack` when `Paper`'s layout does not fit. Cut sheets paint directly; drawn edges and curls run `sheetRecipe`. |
| `PaperRules`, `PaperFastener`, `Tape` | The printed rules, a clip / pin / staple / binder clip, a strip of tape. |
| `PaperInk` (foundation) | `tier(theme)`, `calm(theme)`, `tiltMax(theme)`, `tilt(context, degrees, factor:)` for props and decor. |
| `InkArt(drop: DropKind.tape / .prop)` | A prop's drop shadow. |

Faces in recipe markup (`<!--ll-face:…-->`) need nothing special: `InkSurface` paints any faced frame like upstream `SheetLayers` (casts, then faces and ink runs in order). The painters behind it are public for custom work: `PaperFacePainter`, `PaperShadowPainter`, `PaperRulesPainter`.

### Overlays (`components/overlay/`)

`InkPopup` is the whole popup: give it `open`, `onOpenChange`, a `popupBuilder(context, position)` and the trigger as `child`.

- Placement: `side`, `align`, `sideOffset`, `alignOffset`, `collisionPadding`, `avoidCollisions`, `anchor` (a rect in the trigger's coordinates, for a context menu), or `centered: true` for dialogs, with a `placement` (`center`, `top` for a palette, and the flush `phoneBottom` / `phoneTop`; `DialogMetrics.placement` picks the phone one). `position` gives the side after a flip and `anchorCenter` for an arrow.
- Motion: `PopupMotionStyle.pop` (popovers, menus, tooltips), `.sheetDrop` (dialogs), `.rise` (dialogs on phones), `.fade`, `.none`. It stays mounted through the exit.
- Dismissal: Escape (topmost layer first), outside taps (share `groupId` with a `TapRegion` around the trigger), `dismissOnFocusOutside`; `onDismiss` hears the `OverlayDismissReason`.
- Focus: `autofocus`, `modal` (traps Tab, blocks the app), `restoreFocus` (skipped after an outside tap).
- Barrier: `modal` (clear) or `scrim` (Looseleaf's warm vignette, `OverlayScrim`).

Write the popup on `PaperPopup` (slip, `lift` shadow, hairline when calm, `pointer: PopupPointer.popoverSize` for an arrow; add the pointer's `reach` to `sideOffset`). The pieces are public for layouts `InkPopup` does not cover (an edge sheet): `AnchoredOverlay`, `OverlayPosition.resolve`, `OverlayDismiss`, `OverlayFocus`, `OverlayScrim`, `PopupMotion`. `Popover` and `Tooltip` are the reference ports.

## The widget shape

```dart
class Thing extends StatefulWidget { ... }

class _ThingState extends State<Thing> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = ThingParams(disabled: widget.disabled);
    final source = RecipeInkSource(thingRecipe, params, json: params.toJson());
    return InkInteraction(
      semantics: SemanticsProperties(
        button: true,                     // or checked/mixed, textField, …
        enabled: !widget.disabled,
      ),
      enabled: !widget.disabled,
      onActivate: widget.onPressed,
      states: {...widget.forcedStates, if (widget.on) InkState.checked},
      builder: (context, states) => InkSurface(
        source: source,
        seed: inkSeed(widget.seed),
        states: states,
        child: ...,                       // the content, sized from the CSS
      ),
    );
  }
}
```

Props:

- Keep shadcn's part names and boolean state props (`variant`, `size`, `disabled`, `invalid`). Reuse the recipe's enums (`ButtonVariant`, `ButtonSize`, …) instead of new ones.
- Callbacks and values take Flutter names: `onClick` → `onPressed`, `checked` → `value`, `onCheckedChange` → `onChanged`, `open` / `onOpenChange` stay. A null callback never disables; `disabled` does.
- Always offer `seed` (`String?`), `focusNode`, `autofocus` for focusable widgets, `semanticLabel` when the content may not be text, and `forcedStates` (upstream's `data-hover`, `data-pressed`, `data-focus-visible`) for state grids and goldens.
- Content slots are `Widget`s (`child`, `leading`, `trailing`, `label`), styled through `InkContent`.

## Reading upstream

1. **Recipe params** – the `useInk({ recipe, params, kind, seed })` call in the `.tsx`. Build the same params in Dart; pass `params.toJson()` as `json` so frames share the cache key. Watch for params derived from props or classes (`shape: pill ? "pill" : "default"` from `rounded-full`).
2. **Seed** – `seed` prop, else `useId()`: that is `inkSeed(widget.seed)`.
3. **States** – which CSS rules light layers: `:hover`, `:active`, `:focus-visible`, `:disabled` come from `InkInteraction`; `data-state=checked|indeterminate|open`, `aria-invalid`, `aria-busy` are the component's `states`. The surface handles fades, the hover tilt, the press sink and the checked pop.
4. **Part animations** – `[data-part=swipe]` wipes (`hover:…animate-[ll-wipe…]`) → `InkSurface(swipeOnHover: true)`; `[data-part=reveal]` draw-on (`REVEAL_WHEN_CHECKED`, only after `data-touched`) → `InkSurface(drawOn: touched)`. `data-ink-sink="self"` → `sinkSelf: true`.
5. **Metrics** – the Tailwind classes in the `.tsx` (`cva` variants) plus `src/styles/looseleaf.css`. Tailwind spacing is 4 px per step (`px-4` = 16, `gap-1.5` = 6, `size-9` = 36); write them as `Spacing.d*` (add a token if one is missing). `text-base` is 16 / 1.5, `text-sm` 14 / 20 px, `text-[15px]` keeps the body's 1.55. `font-hand` is `KevinSansFace.hand`, `font-bold` is `w700`. Colors: `text-<token>` maps to `LooseleafColors` (`primary-foreground`, `foreground` → `ink`; `text-link` → `link`; `text-pencil-text` → `pencilText`).
6. **Density** – `compact:` / `calm:` variants become `ByDensity`.
7. **Behavior** – read the docs page (`src/docs/meta/<name>.ts`, its `a11y` list) and examples (`src/docs/examples/<name>/`): keys, focus, what the label does. Build it with Flutter widgets, not translated DOM code.

## Tests

In `test/components/<name>/`:

- `<name>_test.dart`: callbacks (tap and keys), the states handed to `InkSurface`, disabled, semantics (`matchesSemantics`), metrics (sizes per density, padding).
- `<name>_golden_test.dart`: the light theme, every variant and state in one grid, with fixed seeds. Load `InkTextures.instance.load` and `loadKevinSans()` in `setUpAll`, wrap with `componentHost(goldenPanel(...))`, write to `test/components/goldens/<name>-*.png`.

Run `flutter test --update-goldens test/components/<name>`, then open the PNGs and compare them with `.upstream/looseleaf/public/thumbs/<name>.jpg` and the docs examples: label size, padding, alignment, colors.

## Done

- `flutter analyze` and `flutter test` clean in `packages/looseleaf_ui`, `dart format` applied.
- Public API has `///` docs naming the upstream file it mirrors.
- Commit only your paths, adding the barrel line through the script:

```bash
commit_only.sh "feat(<name>): add <Name>" \
  --barrel packages/looseleaf_ui/lib/src/components/components.dart \
  "export 'package:looseleaf_ui/src/components/<name>/<name>.dart';" \
  -- packages/looseleaf_ui/lib/src/components/<name> packages/looseleaf_ui/test/components/<name> \
     packages/looseleaf_ui/test/components/goldens/<name>-*.png
```
