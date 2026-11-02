import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lets a popup's content size to its children, like a block in CSS: the
/// child is laid out with no height limit, so a plain `Column` is as tall as
/// what it holds instead of the whole overlay. Content taller than the
/// overlay is laid out again inside it (a scroll view gets its bounded
/// height then).
///
/// Content wrapping a scroll view that should fill a fixed height needs its
/// own height (`SizedBox`, `ConstrainedBox`), as in upstream's `max-h-*`.
class PopupFit extends SingleChildRenderObjectWidget {
  const PopupFit({super.key, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => RenderPopupFit();
}

/// The render object of [PopupFit].
class RenderPopupFit extends RenderProxyBox {
  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_unbounded(constraints), parentUsesSize: true);
    if (child.size.height > constraints.maxHeight) {
      child.layout(constraints, parentUsesSize: true);
    }
    size = constraints.constrain(child.size);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final free = child.getDryLayout(_unbounded(constraints));
    final fits = free.height <= constraints.maxHeight;
    if (fits) return constraints.constrain(free);
    return constraints.constrain(child.getDryLayout(constraints));
  }

  static BoxConstraints _unbounded(BoxConstraints constraints) =>
      constraints.copyWith(maxHeight: double.infinity);
}
