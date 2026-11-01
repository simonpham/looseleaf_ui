# Code Conventions

## General
- **Dart 3.13+**: records, patterns, switch expressions, collection if/for, dot shorthands where the type is clear.
- **Const**: `const` constructors wherever possible.
- **Lints**: follow `analysis_options.yaml` (`always_use_package_imports`, `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `unawaited_futures`, `avoid_print`, trailing commas preserved). No new warnings.

## Control Flow & Null Safety
- **Never use the `!` operator.** Use pattern matching (`if (x case final v?)`) or local promotion with an early return.
- **Early returns**: guard clauses over `else`. No `else` / `else if` chains: handle edge cases first, keep the main flow flat.
- **No ternaries**: use `switch` expressions (`switch (isDark) { true => a, false => b }`). `??` and `?.` are fine.
- **Patterns**: descriptive names in patterns (`stagedCount`, not `s`).

## Imports & Barrels
- **Package imports only**, never relative, in `lib/` and in tests.
- **Barrel per folder**: every folder with more than one file has a barrel named after the folder (`recipes/recipes.dart`, `widgets/widgets.dart`). Import the barrel, not individual files. Inside a folder, files may import siblings through the parent barrel as long as it creates no initialization cycle.
- **Flutter imports**: `package:flutter/widgets.dart`. Import `material.dart` only where Material APIs are needed; the widgets in `looseleaf_ui` do not use Material.
- `looseleaf_ink` is **pure Dart**: no Flutter imports, no dependencies.

## Architecture
- `apps/*` hold only entry points, assets and platform folders. Features live in `modules/` or `packages/`.
- `modules` depend on `packages`; `packages` never depend on `apps` or `modules`.
- **The ink engine** (`looseleaf_ink`) turns a recipe, a box, params and a seed into SVG markup per state layer (`rest`, `hover`, `pressed`, `focus`, …). It is a faithful port of Looseleaf's `src/lib/ink`: same algorithms, same random streams, same output. Keep a doc comment naming the upstream file each piece mirrors.
- **The Flutter side** (`looseleaf_ui`) paints that markup with its own SVG-subset painter (`InkPainter`), caches frames by key, and shows the layer that matches the widget's state. Widgets keep shadcn/ui's parts and props.

## Feature Module Pattern
Each gallery feature in `modules/gallery/lib/features/<name>/`:
```
features/<name>/
├── models/          # Data models
├── view_models/     # ChangeNotifier-based state
└── ui/
    ├── frames/      # Smart widgets: consume ViewModels via context.select
    ├── pages/       # Top-level screens
    ├── widgets/     # Dumb, reusable components: no business logic, no ViewModels
    └── dialogs/     # Modal overlays
```
Create only the folders a feature needs; each gets its barrel.

## UI
- **Before any new UI**, read the existing widgets next to it and match their style and patterns.
- **Dimensions**: never hardcode numbers for padding, margins, gaps, icon sizes or radii. Use `Spacing` (`Spacing.d16`, `Spacing.d8`, …). Ink geometry inside `looseleaf_ink` is ported math and keeps its numbers.
- **Colors**: never hardcode colors in widgets. Read them from `LooseleafTheme.of(context)` (the paint tokens).
- **Trailing actions in a `Row`**: a row ending in actions, badges or a chevron gets exactly one `Expanded`, holding all the text that may shrink (nest `Flexible`s inside it). Never an `Expanded` beside a `Flexible`, or a `Flexible` with a `Spacer`.
- **File size**: small, focused files. One widget per file; split large files by responsibility.

## State Management
- **ViewModels** extend `ChangeNotifier`.
- **Frames use `context.select`**, never `context.watch`. Provide with `ChangeNotifierProvider.value` and read with `context.select` instead of `ListenableBuilder`.
- **Dispose** every controller, listener, timer and subscription in `dispose()`.

## Coding Style
- **Async**: `unawaited(...)` for futures intentionally not awaited.
- **Logging**: no `print()`.
- **Comments**: good code explains itself: descriptive names, named booleans, early returns. Comment only what the code can't say (why something non-obvious is done, the upstream file a port mirrors). No TODO or placeholder comments. Public API `///` docs are expected and must say more than the name.

## Testing
- `./run_tests.sh` runs every suite. New functionality comes with tests.
- **Parity**: every ported engine piece and recipe is checked against fixtures exported from the original (`tools/parity`, see its README). A recipe drawn with the same seed must give the same markup.

## Git & Commits
- **Conventional commits**: `feat(ink): ...`, `fix(button): ...`, `refactor(painter): ...`, `test(parity): ...`.
- One commit per completed task or logical change; never bundle unrelated work; leave unrelated working-tree edits out.

## Checklist Before Commit
- `flutter analyze` reports no issues; `dart fix --apply && dart format .` run
- No `!` operator, no ternaries, no avoidable `else`
- Barrel imports only, package imports only
- Frames use `context.select`; everything disposed
- No hardcoded colors or dimensions in widgets
- Tests added; parity fixtures green; `./run_tests.sh` passes
- No redundant comments (public API docs excepted)
- One logical change per commit
