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
    // ignore: avoid_print
    print('${layer.name}: ${frame.parts[layer]?.length} chars of SVG');
  }
}
