import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/table/float/table_float_layout.dart';
import 'package:looseleaf_ui/src/components/table/float/table_float_link.dart';

/// Parent data of a floating cell in a [TableFloatLayout].
class TableFloatParentData extends ContainerBoxParentData<RenderBox> {
  /// The slots this cell covers; null for the table itself.
  TableFloatLink? link;

  /// Whether the cell sticks to the top of the scroll view (a sticky
  /// header cell).
  bool stick = false;
}

/// Marks [child] as a floating cell of a [TableFloatLayout], laid out over
/// the slots of [link].
class TableFloat extends ParentDataWidget<TableFloatParentData> {
  const TableFloat({
    super.key,
    required this.link,
    this.stick = false,
    required super.child,
  });

  final TableFloatLink link;
  final bool stick;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData;
    if (data is! TableFloatParentData || renderObject is! RenderBox) return;
    link.content = renderObject;
    if (identical(data.link, link) && data.stick == stick) return;
    data
      ..link = link
      ..stick = stick;
    final parent = renderObject.parent;
    if (parent is RenderObject) parent.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableFloatLayout;
}
