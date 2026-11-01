import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_def.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_markup_parser.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_node.dart';

/// Ink markup parsed once into an immutable display list: one root group per
/// state layer, plus the elements and definitions `url(#id)` and
/// `use href="#id"` point at. Paints are left unresolved, so switching theme
/// repaints without reparsing.
class InkDocument {
  InkDocument({
    required this.layers,
    required this.elements,
    required this.defs,
    required this.usesBlend,
    required this.chars,
  });

  /// Parses one layer of markup as `rest`.
  factory InkDocument.parse(String markup) =>
      InkDocument.parseLayers({'rest': markup});

  /// Parses per-layer markup (`rest`, `hover`, …) into one document; ids are
  /// shared across layers, as in one `<svg>`.
  factory InkDocument.parseLayers(Map<String, String> parts) =>
      InkMarkupParser().parse(parts);

  /// Layer name to its root group, in the order given.
  final Map<String, InkGroupNode> layers;
  final Map<String, InkNode> elements;
  final Map<String, InkDef> defs;

  /// Whether any element blends with `mix-blend-mode`, which needs the
  /// surface painted in its own isolated layer.
  final bool usesBlend;

  /// The markup size in characters, for cache budgets.
  final int chars;

  /// Rendered pattern tiles, keyed by pattern id, theme and resolution.
  final Map<Object, Image> patternTiles = {};
}
