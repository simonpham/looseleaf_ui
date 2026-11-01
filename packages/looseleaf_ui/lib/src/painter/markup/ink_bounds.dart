import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_def.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_node.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_paint.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_style.dart';

/// Measures what each node paints, so layers, masks and pop-in transforms
/// can be sized without walking the tree at paint time.
class InkBounds {
  InkBounds(this._elements);

  final Map<String, InkNode> _elements;
  int _depth = 0;

  /// Measures [node] and its subtree under [parent], storing [InkNode.bounds].
  Rect? measure(InkNode node, InkStyle parent) {
    final bounds = _measure(node, parent);
    node.bounds = bounds;
    return bounds;
  }

  void measureDef(InkDef def) {
    final children = switch (def) {
      InkClipPathDef(:final children) => children,
      InkMaskDef(:final children) => children,
      InkPatternDef(:final children) => children,
      InkGradientDef() => const <InkNode>[],
    };
    for (final child in children) {
      measure(child, InkStyle.initial);
    }
  }

  Rect? _measure(InkNode node, InkStyle parent) {
    final style = node.style.inherit(parent);
    final local = switch (node) {
      InkGroupNode(:final children) => _union(children, style),
      InkShapeNode(:final path) => _shape(path, style),
      InkUseNode(:final href, :final offset) => _use(href, style)?.shift(
        offset,
      ),
      InkImageNode(:final rect) => rect,
      InkTextNode() => null,
    };
    if (local == null) return null;
    final transform = node.effects.transform;
    if (transform == null) return local;
    return transform.applyRect(local);
  }

  Rect? _union(List<InkNode> children, InkStyle style) {
    Rect? out;
    for (final child in children) {
      final rect = measure(child, style);
      if (rect == null) return null;
      out = out?.expandToInclude(rect) ?? rect;
    }
    return out ?? Rect.zero;
  }

  Rect? _use(String href, InkStyle style) {
    final target = _elements[href];
    if (target == null || _depth > 8) return null;
    _depth++;
    final rect = _measure(target, style);
    _depth--;
    return rect;
  }

  static Rect _shape(Path path, InkStyle style) {
    final rect = path.getBounds();
    if (style.stroke is InkNoPaint || style.stroke == null) return rect;
    final half = (style.strokeWidth ?? 1) / 2;
    final miter = switch (style.strokeJoin) {
      StrokeJoin.miter || null => style.strokeMiterLimit ?? 4,
      _ => 1.0,
    };
    return rect.inflate(half * miter + 1);
  }
}
