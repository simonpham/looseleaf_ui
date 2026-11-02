# looseleaf_ink 🦊

The ink engine behind [looseleaf_ui](https://pub.dev/packages/looseleaf_ui): pens, strokes, fills, paper, art and charts, drawn as SVG markup. Pure Dart, no dependencies.

> All credit for the design goes to [Looseleaf](https://github.com/kevintngo/looseleaf) by [@kevintngo](https://github.com/kevintngo). This is a port of its ink engine, MIT like the original. See [THIRD_PARTY_NOTICES.md](https://github.com/simonpham/looseleaf_ui/blob/main/packages/looseleaf_ink/THIRD_PARTY_NOTICES.md).

Want widgets? Use `looseleaf_ui`. This package is for when you want the markup itself: on a server, in a CLI, or in your own painter.

## 🚀 Use it

```dart
import 'package:looseleaf_ink/looseleaf_ink.dart';

void main() {
  final frame = runRecipe(
    buttonRecipe,
    RunRequest(
      box: const Box(120, 40),
      params: const ButtonParams(
        variant: ButtonVariant.primary,
        size: ButtonSize.regular,
      ),
      seed: 'save',
      tier: Tier.hi,
      density: Density.comfortable,
      dir: Dir.ltr,
      knobs: Knobs(),
    ),
  );
  for (final layer in frame.layers) {
    print('${layer.name}: ${frame.parts[layer]?.length} chars of SVG');
  }
}
```

Every layer (`rest`, `hover`, `pressed`, `focus`, …) is its own SVG markup. Same seed, same strokes. Byte for byte the same markup as the original, checked against fixtures exported from its TypeScript.

## Happy Coding 🦊
