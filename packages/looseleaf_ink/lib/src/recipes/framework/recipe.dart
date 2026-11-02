import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Draws a recipe: `(ink, box, params, ctx)`.
typedef RecipeDraw<P> =
    void Function(
      Ink ink,
      Box box,
      P params,
      RecipeContext ctx,
    );

/// Computes a recipe's padding from its box and params.
typedef RecipePad<P> = double Function(Box box, P params, RecipeContext ctx);

final RegExp _idPattern = RegExp(r'^[a-z][a-z0-9]*(-[a-z0-9]+)*$');
final Map<String, Recipe<Object?>> _registry = {};

/// A registered drawing: its id, the layers it can draw, which of them are
/// lazy, its padding and the draw function.
///
/// Mirrors `Recipe` in `src/lib/ink/recipes/index.ts`. Upstream `pad` is
/// `number | fn`: here [pad] holds the number and [padFor] the function.
final class Recipe<P> {
  const Recipe._({
    required this.id,
    required this.kind,
    required this.layers,
    required this.lazy,
    required this.pad,
    required this.padFor,
    required this.draw,
    required this.rev,
  });

  final String id;
  final String kind;
  final List<LayerName> layers;
  final List<LayerName> lazy;

  /// A fixed padding, when the recipe has one.
  final double? pad;

  /// A padding computed after drawing, when [pad] is null.
  final RecipePad<P>? padFor;
  final RecipeDraw<P> draw;

  /// How many times this id was defined.
  final int rev;
}

/// Defines and registers a recipe. Give either [pad] or [padFor].
///
/// Mirrors `defineRecipe` in `src/lib/ink/recipes/index.ts`.
Recipe<P> defineRecipe<P>({
  required String id,
  String? kind,
  required List<LayerName> layers,
  List<LayerName> lazy = const [],
  double? pad,
  RecipePad<P>? padFor,
  required RecipeDraw<P> draw,
}) {
  if (!_idPattern.hasMatch(id)) {
    throw ArgumentError(
      'ink recipe id "$id" must be kebab-case (letters, digits, hyphens)',
    );
  }
  for (final l in lazy) {
    if (!layers.contains(l)) {
      throw ArgumentError(
        'ink recipe "$id": lazy layer "${l.name}" is not in layers',
      );
    }
  }
  if (pad == null && padFor == null) {
    throw ArgumentError('ink recipe "$id": give pad or padFor');
  }
  final recipe = Recipe<P>._(
    id: id,
    kind: kind ?? id,
    layers: layers,
    lazy: lazy,
    pad: pad,
    padFor: padFor,
    draw: draw,
    rev: (_registry[id]?.rev ?? 0) + 1,
  );
  _registry[id] = recipe;
  return recipe;
}

/// The registered recipe with [id], or null.
Recipe<Object?>? getRecipe(String id) => _registry[id];

/// Every registered recipe.
List<Recipe<Object?>> allRecipes() => [..._registry.values];
