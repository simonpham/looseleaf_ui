import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// A 2D affine transform `[a c e; b d f]`, as in SVG's `matrix(a b c d e f)`.
class InkAffine {
  const InkAffine(this.a, this.b, this.c, this.d, this.e, this.f);

  const InkAffine.translate(double x, double y) : this(1, 0, 0, 1, x, y);

  const InkAffine.scale(double x, double y) : this(x, 0, 0, y, 0, 0);

  factory InkAffine.rotate(double degrees, [double cx = 0, double cy = 0]) {
    final radians = degrees * math.pi / 180;
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    return InkAffine.translate(
          cx,
          cy,
        )
        .multiply(InkAffine(cos, sin, -sin, cos, 0, 0))
        .multiply(InkAffine.translate(-cx, -cy));
  }

  factory InkAffine.skewX(double degrees) =>
      InkAffine(1, 0, math.tan(degrees * math.pi / 180), 1, 0, 0);

  factory InkAffine.skewY(double degrees) =>
      InkAffine(1, math.tan(degrees * math.pi / 180), 0, 1, 0, 0);

  static const InkAffine identity = InkAffine(1, 0, 0, 1, 0, 0);

  final double a;
  final double b;
  final double c;
  final double d;
  final double e;
  final double f;

  /// This transform applied after [other]: `this × other`.
  InkAffine multiply(InkAffine other) => InkAffine(
    a * other.a + c * other.b,
    b * other.a + d * other.b,
    a * other.c + c * other.d,
    b * other.c + d * other.d,
    a * other.e + c * other.f + e,
    b * other.e + d * other.f + f,
  );

  Offset apply(Offset point) =>
      Offset(a * point.dx + c * point.dy + e, b * point.dx + d * point.dy + f);

  /// The bounding box of [rect] after this transform.
  Rect applyRect(Rect rect) {
    final corners = [
      apply(rect.topLeft),
      apply(rect.topRight),
      apply(rect.bottomLeft),
      apply(rect.bottomRight),
    ];
    var bounds = Rect.fromPoints(corners[0], corners[1]);
    bounds = bounds.expandToInclude(Rect.fromPoints(corners[2], corners[3]));
    return bounds;
  }

  /// The column-major 4×4 matrix [Canvas.transform] takes.
  Float64List get storage => Float64List.fromList([
    a, b, 0, 0, //
    c, d, 0, 0,
    0, 0, 1, 0,
    e, f, 0, 1,
  ]);

  @override
  bool operator ==(Object other) =>
      other is InkAffine &&
      other.a == a &&
      other.b == b &&
      other.c == c &&
      other.d == d &&
      other.e == e &&
      other.f == f;

  @override
  int get hashCode => Object.hash(a, b, c, d, e, f);
}
