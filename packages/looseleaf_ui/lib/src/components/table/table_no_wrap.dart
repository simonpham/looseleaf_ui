import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Keeps a table cell on one line (upstream `whitespace-nowrap`): its
/// narrowest width is its natural width, so [InkTable] never squeezes it
/// and scrolls sideways instead.
class TableNoWrap extends SingleChildRenderObjectWidget {
  const TableNoWrap({super.key, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoWrap();
}

class _RenderNoWrap extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;
}
