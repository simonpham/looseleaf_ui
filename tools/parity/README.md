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

A recipe port adds an exporter that runs `runRecipe` over its variants (see `ink_button.ts`) and a Dart test that compares `RawFrame.parts` per layer.

Fixtures were last exported from upstream commit `747ba9f`.

Each exporter in `exporters/` imports the original through its `@/` alias and calls `writeFixture` (`write.ts`) with a path under the repo root.
