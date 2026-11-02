# Looseleaf UI 🦊

Hand-drawn Flutter widgets on paper. Every line is drawn with a pen, every surface is paper, with stickers and stamps when you want them.

> All credit for the design goes to [Looseleaf](https://github.com/kevintngo/looseleaf) by [@kevintngo](https://github.com/kevintngo) ([live site](https://kevintngo.github.io/looseleaf/)). This repo is a Flutter port of it, MIT like the original. See [THIRD_PARTY_NOTICES.md](https://github.com/simonpham/looseleaf_ui/blob/main/THIRD_PARTY_NOTICES.md).

> **TL;DR**
> 1. Add `looseleaf_ui` to your `pubspec.yaml`.
> 2. Wrap your app in `LooseleafTheme`.
> 3. Use the widgets. Same parts and props as shadcn/ui.

## 💎 What's inside

- **122 components.** Every shadcn/ui part, plus paper objects, marks, stickers, a sketchpad and a chat kit.
- **60 blocks.** Logins, sign-ups, sidebars, dashboards, settings, pricing, chat, notes and landing sections.
- **Art.** 160 icons, 48 doodles, 96 stickers and stamps, and the pencil-stub mascot in 15 poses. All drawn in code.
- **Kevin Sans.** The hand-drawn typeface from the original, bundled.
- **A gallery app.** Every component with its examples, every block, and the foundations.

## 📦 Install

Requirements: Flutter 3.32+ / Dart 3.8+.

```sh
flutter pub add looseleaf_ui
```

## 🚀 Use it

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(InkTextures.instance.load());
  runApp(
    LooseleafTheme(
      data: const LooseleafThemeData(),
      child: WidgetsApp(
        color: const Color(0xFFE0703C),
        builder: (context, _) => Desk(
          child: Center(
            child: Button(onPressed: () {}, child: const Text('Save changes')),
          ),
        ),
      ),
    ),
  );
}
```

That's it. Every widget takes a `seed`: the same seed always draws the same hand.

A few names differ from shadcn/ui so they don't clash with Flutter's own widgets: `InkIcon`, `InkTable`, `PaperPage`, `InkForm`, `InkRadioGroup`, `InkClipboard`, `InkItem`. The full list is in [COMPONENTS.md](https://github.com/simonpham/looseleaf_ui/blob/main/packages/looseleaf_ui/COMPONENTS.md).

## 🍎 Run the gallery

```sh
./get.sh
cd apps/gallery && flutter run -d macos
```

## 🔍 Same ink as the original

The engine is a faithful port. A recipe drawn with the same seed gives the same strokes as Looseleaf, byte for byte. The tests check that against fixtures exported from the original TypeScript (`tools/parity`).

```sh
./run_tests.sh                 # every suite
tools/sdk/check_min_sdk.sh     # still builds on Flutter 3.32
tools/names/check_clashes.sh   # no name clashes with Flutter
```

## 🗂️ Packages

| Package | What it is |
|---|---|
| `packages/looseleaf_ink` | The ink engine: pens, strokes, fills, paper, art, charts and one recipe per component. Pure Dart, outputs SVG markup. |
| `packages/looseleaf_ui` | The Flutter side: the ink painter, the theme, Kevin Sans and the widgets. |
| `modules/gallery` | The gallery: every component and block with its examples. |
| `apps/gallery` | The gallery app entry point. |

## Happy Coding 🦊
