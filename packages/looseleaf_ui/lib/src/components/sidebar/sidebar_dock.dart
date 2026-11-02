import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reserves [gap] of width in its row (upstream's `sidebar-gap`) and lays
/// [child] out [containerWidth] wide, [offset] from its start edge: the
/// fixed `sidebar-container` that slides past the gap when collapsing.
///
/// Hit testing follows [child] past the reserved box, so the rail on the
/// pad's edge and a pad sliding back in stay reachable.
class SidebarDock extends SingleChildRenderObjectWidget {
  const SidebarDock({
    super.key,
    required this.gap,
    required this.containerWidth,
    required this.offset,
    required super.child,
  });

  /// The width taken in the row.
  final double gap;

  /// The width [child] is laid out at.
  final double containerWidth;

  /// Where [child]'s left edge sits from the gap's left edge.
  final double offset;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSidebarDock(
    gap: gap,
    containerWidth: containerWidth,
    offset: offset,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSidebarDock renderObject,
  ) {
    renderObject
      ..gap = gap
      ..containerWidth = containerWidth
      ..offset = offset;
  }
}

/// The render object of [SidebarDock].
class RenderSidebarDock extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSidebarDock({
    required double gap,
    required double containerWidth,
    required double offset,
  }) : _gap = gap,
       _containerWidth = containerWidth,
       _offset = offset;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  double _containerWidth;
  double get containerWidth => _containerWidth;
  set containerWidth(double value) {
    if (value == _containerWidth) return;
    _containerWidth = value;
    markNeedsLayout();
  }

  double _offset;
  double get offset => _offset;
  set offset(double value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  Offset get _childOffset => Offset(_offset, 0);

  @override
  double computeMinIntrinsicWidth(double height) => _gap;

  @override
  double computeMaxIntrinsicWidth(double height) => _gap;

  @override
  void performLayout() {
    final height = constraints.maxHeight;
    child?.layout(
      BoxConstraints.tightFor(width: _containerWidth, height: height),
    );
    size = constraints.constrain(Size(_gap, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child case final box?) context.paintChild(box, offset + _childOffset);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(Matrix4.translationValues(_offset, 0, 0));
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final box = child;
    if (box == null) return false;
    final hit = result.addWithPaintOffset(
      offset: _childOffset,
      position: position,
      hitTest: (result, transformed) =>
          box.hitTest(result, position: transformed),
    );
    if (hit) result.add(BoxHitTestEntry(this, position));
    return hit;
  }
}
