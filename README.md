# Looseleaf UI 🦊

Hand-drawn Flutter widgets on paper. Every line is drawn with a pen, every surface is paper, with stickers and stamps when you want them.

> All credit for the design goes to [Looseleaf](https://github.com/kevintngo/looseleaf) by [@kevintngo](https://github.com/kevintngo) ([live site](https://kevintngo.github.io/looseleaf/)). This repo is a Flutter port of it, MIT like the original. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## 📦 Packages

| Package | What it is |
|---|---|
| `packages/looseleaf_ink` | The ink engine: pens, strokes, fills, paper, art and one recipe per component. Pure Dart, outputs SVG markup. |
| `packages/looseleaf_ui` | The Flutter side: the ink painter, the theme, Kevin Sans and the widgets. |
| `modules/gallery` | The gallery: every component and block with its examples. |
| `apps/gallery` | The gallery app entry point. |

## 🚀 Run the gallery

```sh
./get.sh
cd apps/gallery && flutter run -d macos
```

## 🔍 Same ink as the original

The engine is a faithful port, so a recipe drawn with the same seed gives the same strokes as Looseleaf. The tests check that against fixtures exported from the original (`tools/parity`).

## Happy Coding 🦊
