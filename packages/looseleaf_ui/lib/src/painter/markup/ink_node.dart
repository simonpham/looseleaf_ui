import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_effects.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_style.dart';

/// One drawable element of parsed ink markup.
sealed class InkNode {
  InkNode({required this.style, required this.effects});

  final InkStyle style;
  final InkEffects effects;

  /// The area this node paints in its parent's coordinates, stroke included;
  /// null when it cannot be known ahead of painting (text, broken refs).
  Rect? bounds;
}

/// `<g>`.
class InkGroupNode extends InkNode {
  InkGroupNode({
    required super.style,
    required super.effects,
    required this.children,
  });

  final List<InkNode> children;
}

/// `<path>`, `<rect>`, `<circle>`, `<ellipse>`, `<line>`, `<polyline>` and
/// `<polygon>`, all turned into a [Path].
class InkShapeNode extends InkNode {
  InkShapeNode({
    required super.style,
    required super.effects,
    required this.path,
    this.pathLength,
  });

  final Path path;

  /// `pathLength`: the author's length, which scales dash arrays.
  final double? pathLength;

  /// Dashed outlines, computed once per dash pattern.
  final Map<String, Path> dashCache = {};
}

/// `<use href="#id">`.
class InkUseNode extends InkNode {
  InkUseNode({
    required super.style,
    required super.effects,
    required this.href,
    required this.offset,
  });

  final String href;

  /// The `x` / `y` attributes.
  final Offset offset;
}

/// `<text>`, a single run of text.
class InkTextNode extends InkNode {
  InkTextNode({
    required super.style,
    required super.effects,
    required this.position,
    required this.text,
  });

  final Offset position;
  final String text;
}

/// `<image>` with a data URI or a built-in texture id.
class InkImageNode extends InkNode {
  InkImageNode({
    required super.style,
    required super.effects,
    required this.href,
    required this.rect,
  });

  final String href;
  final Rect rect;
}
