import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/frame/ink_frame_request.dart';
import 'package:looseleaf_ui/src/frame/ink_markup.dart';
import 'package:looseleaf_ui/src/frame/ink_source.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Draws an ink engine recipe with its params: the adapter between
/// `looseleaf_ink`'s `runRecipe` and the frame cache.
///
/// [json] is the params' upstream object (the params class's `toJson()`); it
/// keys the cache, so two sources with equal [json] share frames.
///
/// ```dart
/// const params = ButtonParams(variant: .primary, size: .regular);
/// RecipeInkSource(buttonRecipe, params, json: params.toJson());
/// ```
class RecipeInkSource<P> extends InkSource {
  RecipeInkSource(
    this.recipe,
    this.params, {
    Map<String, Object?> json = const {},
  }) : paramsKey = ink.stableStringify(json);

  final ink.Recipe<P> recipe;
  final P params;

  @override
  final String paramsKey;

  @override
  String get id => '${recipe.id}@${recipe.rev}';

  @override
  Set<String> get lazyLayers => {for (final layer in recipe.lazy) layer.name};

  @override
  InkMarkup draw(InkFrameRequest request) {
    final frame = ink.runRecipe(
      recipe,
      ink.RunRequest(
        box: ink.Box(request.box.width, request.box.height),
        params: params,
        seed: request.seed,
        tier: switch (request.tier) {
          LooseleafTier.lo => ink.Tier.lo,
          LooseleafTier.hi => ink.Tier.hi,
        },
        density: switch (request.density) {
          LooseleafDensity.comfortable => ink.Density.comfortable,
          LooseleafDensity.compact => ink.Density.compact,
          LooseleafDensity.calm => ink.Density.calm,
        },
        dir: switch (request.textDirection) {
          TextDirection.ltr => ink.Dir.ltr,
          TextDirection.rtl => ink.Dir.rtl,
        },
        knobs: ink.Knobs(
          wobble: request.knobs.wobble,
          misreg: request.knobs.misreg,
          bleed: request.knobs.bleed,
          width: request.knobs.width,
        ),
        pad: request.pad,
        lazy: [
          for (final layer in recipe.lazy)
            if (request.lazy.contains(layer.name)) layer,
        ],
        lazyOnly: request.lazyOnly,
      ),
    );
    return InkMarkup(
      parts: {
        for (final MapEntry(:key, :value) in frame.parts.entries)
          key.name: value,
      },
      pad: frame.pad,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecipeInkSource<P> &&
      identical(other.recipe, recipe) &&
      other.paramsKey == paramsKey;

  @override
  int get hashCode => Object.hash(recipe, paramsKey);
}
