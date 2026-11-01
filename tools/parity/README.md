# Parity fixtures

The ink engine is a faithful port of [Looseleaf](https://github.com/kevintngo/looseleaf)'s `src/lib/ink`. These exporters run the original TypeScript and save its output as JSON fixtures; the Dart tests draw the same inputs and compare.

```sh
git clone --depth 1 https://github.com/kevintngo/looseleaf .upstream/looseleaf
tools/parity/fetch-node.sh                                  # once, on Apple Silicon
tools/parity/export.sh .upstream/looseleaf                  # every exporter
tools/parity/export.sh .upstream/looseleaf ink_core ink_pen # some of them
```

## Why an x64 Node

The Dart port reproduces V8's math bit for bit: `JsMath` ports the fdlibm `sin`, `cos`, `exp`, `log`, `atan` and `atan2` that V8 uses, plus its `Math.hypot`, `Math.round` and `String(number)`. Browsers run that fdlibm as written. Node for arm64 is compiled with fused multiply-adds, so its results drift by one bit now and then (8 of the ~380 parity tests fail on raw floats, though no SVG markup changes).

`fetch-node.sh` downloads the official x64 build of the local Node version into `tools/parity/.node` (gitignored, checksum verified). `export.sh` uses it automatically under Rosetta; set `PARITY_NODE` to pick another binary. `Math.pow` is the one function V8 hands to the platform's C library, so `JsMath.pow` (fdlibm) can differ in the last bit; the engine only uses it for stroke tapers, and the markup has matched in every fixture so far.

## Ink engine fixtures

| Exporter | Fixture (`packages/looseleaf_ink/test/fixtures/`) | Covers |
|---|---|---|
| `ink_math` | `js_math.json` | `Math.*`, `String(n)`, `toFixed` |
| `ink_core` | `core.json` | rng streams and forks, `hashSeed`, `noise1`, `wander`, `n`, `fmtUnits`, paints |
| `ink_geom` | `geom.json` | every helper in `geom.ts` |
| `ink_pen` | `pen.json` | the pen table, `stroke()` and `dot()` per pen family and option |
| `ink_draw` | `shapes.json`, `fills.json` | every `*Lines` function and the `Ink` markup of every shape and fill |
| `ink_builder` | `builder.json` | `Ink` layers, groups, parts, defs, clips, text, lean merging, knobs, masks |
| `ink_button` | `recipes.json`, `button.json` | the recipe framework and `runRecipe(buttonRecipe)` frames |
| `ink_controls_fields` | `controls_fields.json`, `controls_fields_tiles.json` | field frames, input, textarea, select family, combobox, field choice and error, input group, OTP slot and caret, prompt input |
| `ink_controls_toggles` | `controls_toggles.json`, `controls_toggles_extra.json` | checkbox, radio, switch, toggle, toggle group, slider, progress, spinner mark, skeleton and item tiles |
| `ink_controls_surfaces` | `controls_surfaces.json`, `controls_surfaces_helpers.json` | accordion, alert, alert dialog, avatar, badge, breadcrumb, button group, card, hover card, kbd, overlay, sheet, table tiles |
| `ink_controls_navigation` | `controls_navigation.json`, `controls_navigation_tiles.json` | calendar, command, menubar, navigation menu, resizable, scroll area, sidebar, tabs |
| `ink_pencil_tiles` | `pencil_tiles.json` | edge, hatch and circle tiles |
| `ink_marks_text` | `marks_text.json` | text marks (underline, strike, scribble, highlight, tally, arrow, bracket, circled, quote, signature, squiggle, margin bracket, marker rule) and their helpers, boil knobs |
| `ink_marks_surfaces` | `marks_surfaces.json` | attachment, bubble, carousel, code block, corkboard, dropzone, empty, flip card, peel corner |
| `ink_marks_scenes` | `marks_scenes.json` | confetti pieces and flights, polaroid scenes, rating, receipt and barcode, reveal nib, ribbon, stamp button |
| `ink_marks_tools` | `marks_tools.json` | sketchpad recipes and stroke markup, sticker board item, sticker sheet, stepper, tear-off, typewriter plan and caret, typing indicator |
| `ink_art` | `art_core_*.json`, `art_icons_*.json`, `art_doodles_*.json`, `art_stickers_*.json`, `art_mascot_*.json`, `art_scenes_*.json` | the art DSL, lettering, badges and stamps; every icon, doodle, sticker, mascot pose, mascot prop and frame, and scene through `drawSkeleton`, `renderSticker` and `drawMascot` at several sizes, tiers and options (compact JSON, split under 900 KB) |
| `ink_art_data` | `lib/src/art/{icons,doodles,stickers,mascots,scenes,props}`, `lib/src/art/text/glyph_data.dart` | not a fixture: generates the Dart art catalog and glyph data from the evaluated upstream tables, then runs `dart format` |
| `ink_paper` | `paper.json` | stocks, rule geometry and CSS layers, sheet shadows, drops, tilts, tile offsets, edge specs, `sheetOutline` per edge kind, face marks, `faceLook`, `faceClip`, `translatePath`, `pathBox`, `faceSvg`, `renderFaces` |
| `ink_paper_props` | `paper_props.json` | every paper prop (tape kinds and ends, clip, pin, staple, binder clip, stitches, rubber band, coffee ring, sticky curl, ruler) |
| `ink_paper_textures` | `paper_textures.json` | paper and desk backgrounds, texture CSS vars, SVG pattern and grain mask defs (tile images swapped for `{tile:<name>}`) |

A recipe port adds an exporter that runs `runRecipe` over its variants (see `ink_button.ts`, or `runCases`/`spread` in `recipe_cases.ts`) and a Dart test that compares `RawFrame.parts` per layer.

Fixtures were last exported from upstream commit `747ba9f`.

Each exporter in `exporters/` imports the original through its `@/` alias and calls `writeFixture` (`write.ts`) with a path under the repo root.
