import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/table/float/table_float.dart';

/// Lays out a table grid (the first child) and then its floating cells
/// ([TableFloat]s) over the slots they cover: a cell spanning columns, or
/// a header cell that sticks to the top while the body scrolls.
class TableFloatLayout extends MultiChildRenderObjectWidget {
  const TableFloatLayout({super.key, this.stick, required super.children});

  /// How far the sticky cells move down: the scroll offset of the table's
  /// own scroll view.
  final ValueListenable<double>? stick;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderTableFloatLayout(stick);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTableFloatLayout renderObject,
  ) {
    renderObject.stick = stick;
  }
}

/// The render object of a [TableFloatLayout].
class RenderTableFloatLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableFloatParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableFloatParentData> {
  RenderTableFloatLayout(this._stick);

  ValueListenable<double>? _stick;
  double _stickLimit = 0;

  ValueListenable<double>? get stick => _stick;

  set stick(ValueListenable<double>? value) {
    if (identical(value, _stick)) return;
    if (attached) _stick?.removeListener(markNeedsPaint);
    _stick = value;
    if (attached) _stick?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double get _stuck =>
      (_stick?.value ?? 0).clamp(0, math.max(0, _stickLimit)).toDouble();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _stick?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _stick?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableFloatParentData) {
      child.parentData = TableFloatParentData();
    }
  }

  Iterable<RenderBox> get _floats sync* {
    var child = firstChild;
    if (child == null) return;
    child = childAfter(child);
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      firstChild?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      firstChild?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      firstChild?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      firstChild?.getMaxIntrinsicHeight(width) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      firstChild?.getDryLayout(constraints) ?? constraints.smallest;

  @override
  void performLayout() {
    final table = firstChild;
    if (table == null) {
      size = constraints.smallest;
      return;
    }
    invokeLayoutCallback<BoxConstraints>((_) {
      for (final cell in _floats) {
        final link = (cell.parentData as TableFloatParentData).link;
        for (final slot in [...?link?.slots]) {
          slot.markNeedsLayout();
        }
      }
      table.markNeedsLayout();
    });
    table.layout(constraints, parentUsesSize: true);
    (table.parentData as TableFloatParentData).offset = Offset.zero;
    var stickBottom = 0.0;
    for (final cell in _floats) {
      final data = cell.parentData as TableFloatParentData;
      final rect = _cover(data, table);
      cell.layout(BoxConstraints.tight(rect.size));
      data.offset = rect.topLeft;
      if (data.stick) stickBottom = math.max(stickBottom, rect.bottom);
    }
    size = table.size;
    _stickLimit = size.height - stickBottom;
  }

  Rect _cover(TableFloatParentData data, RenderBox table) {
    final link = data.link;
    if (link == null) return Rect.zero;
    var rect = Rect.zero;
    for (final (index, slot) in link.slots.indexed) {
      final size = link.sizes[slot];
      if (size == null) continue;
      final box = MatrixUtils.transformRect(
        slot.getTransformTo(table),
        Offset.zero & size,
      );
      rect = switch (index) {
        0 => box,
        _ => rect.expandToInclude(box),
      };
    }
    return rect;
  }

  Offset _shift(RenderBox child) =>
      switch ((child.parentData as TableFloatParentData).stick) {
        true => Offset(0, _stuck),
        false => Offset.zero,
      };

  @override
  void paint(PaintingContext context, Offset offset) {
    final table = firstChild;
    if (table == null) return;
    context.paintChild(table, offset);
    for (final stuck in [false, true]) {
      for (final cell in _floats) {
        final data = cell.parentData as TableFloatParentData;
        if (data.stick != stuck) continue;
        context.paintChild(cell, offset + data.offset + _shift(cell));
      }
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final data = child.parentData as TableFloatParentData;
    final at = data.offset + _shift(child);
    transform.translateByDouble(at.dx, at.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final stuck in [true, false]) {
      for (final cell in _floats.toList().reversed) {
        final data = cell.parentData as TableFloatParentData;
        if (data.stick != stuck) continue;
        final hit = result.addWithPaintOffset(
          offset: data.offset + _shift(cell),
          position: position,
          hitTest: (result, transformed) =>
              cell.hitTest(result, position: transformed),
        );
        if (hit) return true;
      }
    }
    final table = firstChild;
    if (table == null) return false;
    return result.addWithPaintOffset(
      offset: Offset.zero,
      position: position,
      hitTest: (result, transformed) =>
          table.hitTest(result, position: transformed),
    );
  }
}
