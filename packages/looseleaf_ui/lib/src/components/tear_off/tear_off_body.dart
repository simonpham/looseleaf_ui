import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The part of a [TearOff] that stays: a flat sheet perforated on the
/// stub's side, torn there once the stub is off.
///
/// Mirrors `TearOffBody` in upstream `src/components/ui/tear-off.tsx`.
class TearOffBody extends StatelessWidget {
  const TearOffBody({
    super.key,
    required this.child,
    this.stock = StockName.paper,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(Spacing.d16),
    this.seed,
  });

  /// What is printed on the ticket.
  final Widget child;

  final StockName stock;

  /// The width, padding included (upstream `w-64`); beside a stub it gives
  /// way to a narrower parent.
  final double? width;

  /// A fixed height, padding included.
  final double? height;

  /// `p-4`.
  final EdgeInsetsGeometry padding;

  /// Pins the sheet's edges and tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = TearOffScope.of(context);
    final side = scope.sides(Directionality.of(context)).body;
    return _PreferredWidth(
      width: width,
      child: SizedBox(
        height: height,
        child: Paper(
          stock: stock,
          edge: scope.edge(side),
          tilt: false,
          padding: padding,
          seed: seed,
          child: child,
        ),
      ),
    );
  }
}

/// Takes [width] when the parent allows it, less when it does not, and
/// measures its child's height at that width, so a flexible body inside an
/// intrinsic-height ticket wraps its text the same way when measured.
class _PreferredWidth extends SingleChildRenderObjectWidget {
  const _PreferredWidth({required this.width, super.child});

  final double? width;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPreferredWidth(width);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPreferredWidth renderObject,
  ) {
    renderObject.width = width;
  }
}

class _RenderPreferredWidth extends RenderProxyBox {
  _RenderPreferredWidth(this._width);

  double? _width;

  double? get width => _width;

  set width(double? value) {
    if (value == _width) return;
    _width = value;
    markNeedsLayout();
  }

  double _fit(double available) => switch (_width) {
    null => available,
    final preferred => math.min(preferred, available),
  };

  @override
  double computeMinIntrinsicWidth(double height) =>
      _width ?? super.computeMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _width ?? super.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      super.computeMinIntrinsicHeight(_fit(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      super.computeMaxIntrinsicHeight(_fit(width));

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      super.computeDryLayout(_constraintsFor(constraints));

  @override
  void performLayout() {
    final box = child;
    final inner = _constraintsFor(constraints);
    if (box == null) {
      size = inner.smallest;
      return;
    }
    box.layout(inner, parentUsesSize: true);
    size = box.size;
  }

  BoxConstraints _constraintsFor(BoxConstraints constraints) =>
      switch (_width) {
        null => constraints,
        final preferred => constraints.tighten(width: preferred),
      };
}
