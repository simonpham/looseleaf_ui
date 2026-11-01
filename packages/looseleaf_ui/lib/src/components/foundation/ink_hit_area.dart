import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Grows [child]'s hit area by [slop] without changing its layout, like
/// upstream's `after:absolute after:-inset-1.5` hit pseudo-element.
///
/// Pointers in the slop reach [child] at the nearest point of its box. The
/// parent still has to hit-test this widget: slop beyond the parent's own
/// bounds is not reachable.
class InkHitArea extends SingleChildRenderObjectWidget {
  const InkHitArea({super.key, required this.slop, super.child});

  /// How far the hit area reaches past each side.
  final EdgeInsets slop;

  @override
  RenderInkHitArea createRenderObject(BuildContext context) =>
      RenderInkHitArea(slop);

  @override
  void updateRenderObject(BuildContext context, RenderInkHitArea renderObject) {
    renderObject.slop = slop;
  }
}

/// The render object of [InkHitArea].
class RenderInkHitArea extends RenderProxyBox {
  RenderInkHitArea(this.slop);

  EdgeInsets slop;

  static const double _inside = 0.001;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.isEmpty) return false;
    if (!slop.inflateRect(Offset.zero & size).contains(position)) return false;
    final nearest = Offset(
      position.dx.clamp(0, math.max(0, size.width - _inside)),
      position.dy.clamp(0, math.max(0, size.height - _inside)),
    );
    return super.hitTest(result, position: nearest);
  }
}
