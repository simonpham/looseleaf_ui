import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Sets [child] smaller, as a whole, when the space is narrower than
/// [widest], the natural width of its widest word, so that word fits on a
/// line instead of breaking mid-word. The child is laid out at the
/// unscaled width and drawn scaled down.
class LetteringFit extends SingleChildRenderObjectWidget {
  const LetteringFit({super.key, required this.widest, super.child});

  /// The natural width of the widest word.
  final double widest;

  @override
  RenderLetteringFit createRenderObject(BuildContext context) =>
      RenderLetteringFit(widest);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLetteringFit renderObject,
  ) => renderObject.widest = widest;
}

/// The render object of a [LetteringFit].
class RenderLetteringFit extends RenderProxyBox {
  RenderLetteringFit(this._widest);

  double _widest;
  double _scale = 1;

  /// The natural width of the widest word.
  double get widest => _widest;
  set widest(double value) {
    if (value == _widest) return;
    _widest = value;
    markNeedsLayout();
  }

  double _scaleFor(double maxWidth) {
    if (!maxWidth.isFinite || _widest <= 0) return 1;
    return math.min(1, maxWidth / _widest);
  }

  BoxConstraints _inner(BoxConstraints constraints, double scale) =>
      BoxConstraints(
        minWidth: constraints.minWidth / scale,
        maxWidth: constraints.maxWidth / scale,
        minHeight: constraints.minHeight / scale,
        maxHeight: constraints.maxHeight / scale,
      );

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  double computeMinIntrinsicHeight(double width) {
    final scale = _scaleFor(width);
    return super.computeMinIntrinsicHeight(width / scale) * scale;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final scale = _scaleFor(width);
    return super.computeMaxIntrinsicHeight(width / scale) * scale;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final scale = _scaleFor(constraints.maxWidth);
    return constraints.constrain(
      child.getDryLayout(_inner(constraints, scale)) * scale,
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    _scale = _scaleFor(constraints.maxWidth);
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_inner(constraints, _scale), parentUsesSize: true);
    size = constraints.constrain(child.size * _scale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (_scale == 1) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer as TransformLayer?,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) =>
      transform.multiply(_transform);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintTransform(
        transform: _transform,
        position: position,
        hitTest: (result, position) =>
            child?.hitTest(result, position: position) ?? false,
      );
}
