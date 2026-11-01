import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// UI density: `calm` turns the ink down (lo tier, no misregistration).
enum Density { comfortable, compact, calm }

/// Text direction.
enum Dir { ltr, rtl }

/// The size a recipe draws into.
///
/// Mirrors `Box` in `src/lib/ink/recipes/index.ts`.
final class Box {
  /// A `w` × `h` box.
  const Box(this.w, this.h);

  final double w;
  final double h;

  @override
  bool operator ==(Object other) =>
      other is Box && other.w == w && other.h == h;

  @override
  int get hashCode => Object.hash(w, h);

  @override
  String toString() => 'Box($w, $h)';
}

/// The order layers are stacked in, bottom first.
///
/// Mirrors `INK_LAYER_ORDER` in `src/lib/ink/recipes/index.ts`.
const List<LayerName> inkLayerOrder = [
  LayerName.rest,
  LayerName.disabled,
  LayerName.invalid,
  LayerName.checked,
  LayerName.indeterminate,
  LayerName.open,
  LayerName.busy,
  LayerName.hover,
  LayerName.pressed,
  LayerName.focus,
];

/// [names] sorted by [inkLayerOrder] (stable).
///
/// Mirrors `orderLayers` in `src/lib/ink/recipes/index.ts`.
List<LayerName> orderLayers(Iterable<LayerName> names) {
  int rank(LayerName k) => switch (inkLayerOrder.indexOf(k)) {
    -1 => inkLayerOrder.length,
    final i => i,
  };
  final indexed = [
    for (final (i, name) in names.indexed) (i, name),
  ];
  indexed.sort((a, b) {
    final byRank = rank(a.$2) - rank(b.$2);
    if (byRank != 0) return byRank;
    return a.$1 - b.$1;
  });
  return [for (final (_, name) in indexed) name];
}

/// What a recipe sees besides its box and params.
///
/// Mirrors `RecipeContext` in `src/lib/ink/recipes/index.ts`.
abstract interface class RecipeContext {
  Tier get tier;
  Density get density;
  bool get calm;
  Knobs get knobs;
  Dir get dir;

  /// The recipe seed, `<request seed>|<recipe id>`.
  String get seed;

  /// Whether the caller asked for the lazy [layer].
  bool wants(LayerName layer);

  /// Draws a lazy layer into its own [Ink] (seeded `<seed>|<layer>`), only
  /// when the caller asked for it.
  void lazy(LayerName layer, void Function(Ink ink) fn);

  /// Only lazy layers are wanted: skip the eager drawing.
  bool get lazyOnly;
}

/// The default knobs, all 1.
///
/// Mirrors `DEFAULT_KNOBS` in `src/lib/ink/recipes/index.ts`.
Knobs defaultKnobs() => Knobs();

/// The knobs a density draws with.
///
/// Mirrors `resolveKnobs` in `src/lib/ink/recipes/index.ts`.
Knobs resolveKnobs(Knobs themeKnobs, Density density) => switch (density) {
  Density.calm => Knobs(bleed: themeKnobs.bleed),
  Density.compact => themeKnobs.copyWith(
    misreg: themeKnobs.misreg * 0.85,
    width: themeKnobs.width * 0.94,
  ),
  Density.comfortable => themeKnobs,
};
