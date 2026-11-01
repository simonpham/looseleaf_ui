import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Something drawn into a [Scope] bucket.
///
/// Mirrors `Item` in `src/lib/ink/builder.ts`.
sealed class Item {}

/// A filled (or stroked) path.
final class PathItem extends Item {
  /// A path item.
  PathItem({
    required this.d,
    required this.fill,
    required this.op,
    this.evenOdd = false,
    this.stroke,
    this.sw,
    this.clip,
  });

  String d;
  final PaintKey fill;
  final double op;
  final bool evenOdd;
  final PaintKey? stroke;
  final double? sw;
  final String? clip;

  /// A copy with another opacity.
  PathItem withOp(double op) => PathItem(
    d: d,
    fill: fill,
    op: op,
    evenOdd: evenOdd,
    stroke: stroke,
    sw: sw,
    clip: clip,
  );
}

/// Raw SVG markup.
final class RawItem extends Item {
  /// Raw markup.
  RawItem(this.raw);

  final String raw;
}

/// A nested group.
final class ScopeItem extends Item {
  /// A nested scope.
  ScopeItem(this.scope);

  final Scope scope;
}

/// Items bucketed by material, with optional group attributes.
///
/// Mirrors `Scope` in `src/lib/ink/builder.ts`.
final class Scope {
  /// A scope.
  Scope([this.attrs]);

  /// The items per material, in insertion order.
  final Map<Material, List<Item>> buckets = {};

  /// The group attributes, for nested scopes.
  final GroupAttrs? attrs;

  /// Adds [item] to the [mat] bucket.
  void add(Material mat, Item item) => (buckets[mat] ??= []).add(item);
}
