import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_affine.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_node.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_paint.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_scalar.dart';

/// A non-drawing definition referenced by `url(#id)`.
sealed class InkDef {
  const InkDef();
}

/// `<clipPath>`: the union of its shapes.
class InkClipPathDef extends InkDef {
  const InkClipPathDef(this.children, {this.transform});

  final List<InkNode> children;
  final InkAffine? transform;
}

/// `<mask>`: a luminance mask over [region] (user space), or unbounded.
class InkMaskDef extends InkDef {
  const InkMaskDef(this.children, {this.region, this.boundingBoxRegion});

  final List<InkNode> children;
  final Rect? region;

  /// The region as fractions of the masked element's box (`maskUnits`
  /// `objectBoundingBox`, the SVG default).
  final Rect? boundingBoxRegion;
}

/// One `<stop>` of a gradient.
class InkStop {
  const InkStop(this.offset, this.color, this.opacity);

  final double offset;
  final InkPaint color;
  final InkScalar opacity;
}

/// `<linearGradient>` and `<radialGradient>`.
class InkGradientDef extends InkDef {
  const InkGradientDef({
    required this.radial,
    required this.stops,
    required this.userSpace,
    required this.from,
    required this.to,
    required this.radius,
    this.transform,
  });

  final bool radial;
  final List<InkStop> stops;

  /// `gradientUnits="userSpaceOnUse"`; otherwise coordinates are fractions
  /// of the painted shape's box.
  final bool userSpace;

  /// The start point (linear) or center (radial).
  final Offset from;

  /// The end point (linear); unused for radial.
  final Offset to;
  final double radius;
  final InkAffine? transform;
}

/// `<pattern>` with `patternUnits="userSpaceOnUse"`.
class InkPatternDef extends InkDef {
  const InkPatternDef(this.tile, this.children, {this.transform});

  final Rect tile;
  final List<InkNode> children;
  final InkAffine? transform;
}
