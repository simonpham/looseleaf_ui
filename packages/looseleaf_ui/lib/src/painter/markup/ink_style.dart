import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_paint.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_scalar.dart';

/// The inherited presentation attributes of one element; null means
/// "inherit from the parent" (or from the `use` that instantiates it).
class InkStyle {
  const InkStyle({
    this.fill,
    this.fillOpacity,
    this.fillRule,
    this.stroke,
    this.strokeWidth,
    this.strokeOpacity,
    this.strokeCap,
    this.strokeJoin,
    this.strokeMiterLimit,
    this.dashArray,
    this.dashOffset,
    this.clipRule,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.textAnchor,
  });

  final InkPaint? fill;
  final InkScalar? fillOpacity;
  final PathFillType? fillRule;
  final InkPaint? stroke;
  final double? strokeWidth;
  final InkScalar? strokeOpacity;
  final StrokeCap? strokeCap;
  final StrokeJoin? strokeJoin;
  final double? strokeMiterLimit;

  /// The dash pattern; empty for `none`.
  final List<double>? dashArray;
  final double? dashOffset;
  final PathFillType? clipRule;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;

  /// `start`, `middle` or `end`.
  final String? textAnchor;

  static const InkStyle empty = InkStyle();

  /// The SVG initial values: black fill, no stroke, width 1, butt caps, miter joins.
  static const InkStyle initial = InkStyle(
    fill: InkColorPaint(Color(0xFF000000)),
    fillOpacity: InkScalar.value(1),
    fillRule: PathFillType.nonZero,
    stroke: InkNoPaint(),
    strokeWidth: 1,
    strokeOpacity: InkScalar.value(1),
    strokeCap: StrokeCap.butt,
    strokeJoin: StrokeJoin.miter,
    strokeMiterLimit: 4,
    dashArray: [],
    dashOffset: 0,
    clipRule: PathFillType.nonZero,
    fontFamily: 'var(--font-hand)',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    textAnchor: 'start',
  );

  bool get isEmpty => identical(this, empty);

  /// This style's own values over [parent]'s.
  InkStyle inherit(InkStyle parent) {
    if (isEmpty) return parent;
    return InkStyle(
      fill: fill ?? parent.fill,
      fillOpacity: fillOpacity ?? parent.fillOpacity,
      fillRule: fillRule ?? parent.fillRule,
      stroke: stroke ?? parent.stroke,
      strokeWidth: strokeWidth ?? parent.strokeWidth,
      strokeOpacity: strokeOpacity ?? parent.strokeOpacity,
      strokeCap: strokeCap ?? parent.strokeCap,
      strokeJoin: strokeJoin ?? parent.strokeJoin,
      strokeMiterLimit: strokeMiterLimit ?? parent.strokeMiterLimit,
      dashArray: dashArray ?? parent.dashArray,
      dashOffset: dashOffset ?? parent.dashOffset,
      clipRule: clipRule ?? parent.clipRule,
      fontFamily: fontFamily ?? parent.fontFamily,
      fontSize: fontSize ?? parent.fontSize,
      fontWeight: fontWeight ?? parent.fontWeight,
      textAnchor: textAnchor ?? parent.textAnchor,
    );
  }
}
