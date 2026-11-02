import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/table/float/table_float_link.dart';

/// An empty table grid cell that keeps room for a floating cell: as wide
/// as its column and as tall as the cell needs.
class TableFloatSlot extends LeafRenderObjectWidget {
  const TableFloatSlot({super.key, required this.link});

  final TableFloatLink link;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderTableFloatSlot(link);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTableFloatSlot renderObject,
  ) {
    renderObject.link = link;
  }
}

/// The render box of a [TableFloatSlot].
class RenderTableFloatSlot extends RenderBox {
  RenderTableFloatSlot(this._link) {
    _link.slots.add(this);
  }

  TableFloatLink _link;

  TableFloatLink get link => _link;

  set link(TableFloatLink value) {
    if (identical(value, _link)) return;
    _link.slots.remove(this);
    _link.sizes.remove(this);
    _link = value;
    _link.slots.add(this);
    markNeedsLayout();
  }

  @override
  void dispose() {
    _link.slots.remove(this);
    _link.sizes.remove(this);
    super.dispose();
  }

  @override
  double computeMinIntrinsicWidth(double height) => _link.minWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _link.maxWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _link.height(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _link.height(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    Size(constraints.maxWidth, _link.height(constraints.maxWidth)),
  );

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
    _link.sizes[this] = size;
  }
}
