# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Looseleaf UI is a Flutter port of [Looseleaf](https://github.com/kevintngo/looseleaf) (MIT, credited in `THIRD_PARTY_NOTICES.md`): hand-drawn components on paper. **Dart 3.8+ / Flutter 3.32+**, a Flutter workspace monorepo.

Code conventions (mandatory): [CONVENTIONS.md](CONVENTIONS.md) (`AGENTS.md` is a copy; keep them identical).

## Common Commands

```bash
./get.sh                                   # install dependencies
./run_tests.sh                             # every test suite
cd apps/gallery && flutter run -d macos    # the gallery

cd packages/looseleaf_ink && flutter test test/pen_test.dart   # one file
flutter analyze apps modules packages
tools/sdk/check_min_sdk.sh                 # analyze with the oldest supported Flutter (3.32.8, via fvm)

# Regenerate parity fixtures from the original (see tools/parity/README.md)
tools/parity/export.sh <path to a looseleaf checkout>
```

**Workspace gotcha**: use `flutter test` / `flutter pub run`, also in the pure Dart package.

## Architecture

| Directory | Purpose |
|-----------|---------|
| `packages/looseleaf_ink/` | Ink engine, pure Dart: rng, noise, pens, strokes, shapes, fills, the `Ink` builder, recipes (one per component), paper, art, charts. Outputs SVG markup per state layer |
| `packages/looseleaf_ui/` | Flutter: the SVG-subset `InkPainter`, frame cache, `LooseleafTheme` (paint tokens, Kevin Sans), `Spacing`, and the widgets. Porting a component: [COMPONENTS.md](packages/looseleaf_ui/COMPONENTS.md) |
| `modules/gallery/` | The gallery: component pages, examples, blocks |
| `apps/gallery/` | Entry point only |
| `tools/parity/` | Exports fixtures from the original TypeScript for the parity tests |

## Porting Rules

- The engine is a faithful port: same algorithms, same random streams, same number formatting, so the same seed gives the same markup. JS semantics matter: `Math.imul`, `>>>`, `Math.round` (half up), `Number.toString(36)`.
- Widgets keep shadcn/ui's parts and props, and Looseleaf's look. Behavior (keyboard, focus, semantics) uses Flutter's own widgets, not translated DOM code.
- Commits: conventional commits, one logical change per commit.
