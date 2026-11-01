import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Everything [runRecipe] needs.
///
/// Mirrors `RunRequest` in `src/lib/ink/recipes/index.ts`.
final class RunRequest<P> {
  /// A request.
  const RunRequest({
    required this.box,
    required this.params,
    required this.seed,
    required this.tier,
    required this.density,
    required this.dir,
    required this.knobs,
    this.pad,
    this.lazy = const [],
    this.lazyOnly = false,
  });

  final Box box;
  final P params;
  final String seed;
  final Tier tier;
  final Density density;
  final Dir dir;
  final Knobs knobs;

  /// Overrides the recipe's padding.
  final double? pad;

  /// The lazy layers to draw.
  final List<LayerName> lazy;

  /// Draw only the [lazy] layers.
  final bool lazyOnly;
}

/// A drawn recipe: non-empty markup per layer, in stacking order.
///
/// Mirrors `RawFrame` in `src/lib/ink/recipes/index.ts`.
final class RawFrame {
  /// A frame.
  const RawFrame({
    required this.parts,
    required this.layers,
    required this.lazyLayers,
    required this.pad,
    required this.w,
    required this.h,
  });

  /// SVG markup per layer (layers that drew nothing are left out).
  final Map<LayerName, String> parts;

  /// The layers in [parts], in [inkLayerOrder].
  final List<LayerName> layers;

  /// Which of [layers] came from lazy drawing.
  final List<LayerName> lazyLayers;

  /// Padding around the box, in pixels.
  final double pad;
  final double w;
  final double h;
}

/// Counts [runRecipe] calls (`runCounter` upstream).
abstract final class RunCounter {
  /// Runs so far.
  static int runs = 0;
}

final class _Context implements RecipeContext {
  _Context({
    required this.tier,
    required this.density,
    required this.calm,
    required this.knobs,
    required this.dir,
    required this.seed,
    required this.lazyOnly,
    required this.wanted,
    required this.box,
    required this.pad0,
  });

  @override
  final Tier tier;
  @override
  final Density density;
  @override
  final bool calm;
  @override
  final Knobs knobs;
  @override
  final Dir dir;
  @override
  final String seed;
  @override
  final bool lazyOnly;
  final Set<LayerName> wanted;
  final Box box;
  final double? pad0;
  final Map<LayerName, String> lazyParts = {};

  @override
  bool wants(LayerName layer) => wanted.contains(layer);

  @override
  void lazy(LayerName layer, void Function(Ink ink) fn) {
    if (!wanted.contains(layer)) return;
    final li = Ink('$seed|${layer.name}', tier: tier, calm: calm, knobs: knobs);
    li.layer(layer, () => fn(li));
    lazyParts[layer] =
        li.toSvg(w: box.w, h: box.h, pad: pad0 ?? 12).parts[layer] ?? '';
  }
}

/// Draws [recipe] for [req]: the eager layers into one [Ink] seeded
/// `<seed>|<recipe id>`, each wanted lazy layer into its own.
///
/// Mirrors `runRecipe` in `src/lib/ink/recipes/index.ts`.
RawFrame runRecipe<P>(Recipe<P> recipe, RunRequest<P> req) {
  final box = req.box;
  final calm = req.density == Density.calm;
  final tier = switch (calm) {
    true => Tier.lo,
    false => req.tier,
  };
  final seed = '${req.seed}|${recipe.id}';
  final pad0 = req.pad ?? recipe.pad;
  final ctx = _Context(
    tier: tier,
    density: req.density,
    calm: calm,
    knobs: req.knobs,
    dir: req.dir,
    seed: seed,
    lazyOnly: req.lazyOnly,
    wanted: {...req.lazy},
    box: box,
    pad0: pad0,
  );
  final ink = Ink(seed, tier: tier, calm: calm, knobs: req.knobs);
  RunCounter.runs++;
  recipe.draw(ink, box, req.params, ctx);
  final pad = req.pad ?? recipe.pad ?? _padFor(recipe, box, req.params, ctx);
  final parts = <LayerName, String>{};
  if (!req.lazyOnly) {
    final res = ink.toSvg(w: box.w, h: box.h, pad: pad);
    for (final k in res.layers) {
      final markup = res.parts[k] ?? '';
      if (markup.isNotEmpty) parts[k] = markup;
    }
  }
  final lazyLayers = <LayerName>[];
  for (final MapEntry(key: k, value: markup) in ctx.lazyParts.entries) {
    if (markup.isEmpty) continue;
    parts[k] = markup;
    lazyLayers.add(k);
  }
  return RawFrame(
    parts: parts,
    layers: orderLayers(parts.keys),
    lazyLayers: orderLayers(lazyLayers),
    pad: pad,
    w: box.w,
    h: box.h,
  );
}

double _padFor<P>(Recipe<P> recipe, Box box, P params, RecipeContext ctx) =>
    switch (recipe.padFor) {
      final RecipePad<P> padFor => padFor(box, params, ctx),
      null => 12,
    };
