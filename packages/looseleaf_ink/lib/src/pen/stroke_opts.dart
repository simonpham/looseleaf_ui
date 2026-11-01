import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Options for one stroke. Every field is optional; null means "not set",
/// like a missing key upstream.
///
/// Mirrors `StrokeOpts` in `src/lib/ink/types.ts`.
final class StrokeOpts {
  /// Stroke options.
  const StrokeOpts({
    this.tier,
    this.wobble,
    this.speed,
    this.start,
    this.end,
    this.width,
    this.alpha,
    this.color,
    this.poly,
    this.round,
    this.raw,
    this.dry,
    this.press,
    this.simple,
  });

  final Tier? tier;
  final double? wobble;
  final double? speed;
  final StrokeStart? start;
  final StrokeEnd? end;
  final double? width;
  final double? alpha;
  final PaintKey? color;

  /// Straight segments between the points instead of a spline.
  final bool? poly;

  /// Corner fillet radius for [poly] strokes.
  final double? round;

  /// No wobble at all.
  final bool? raw;
  final double? dry;

  /// Pressure along the stroke, `t` in `[0, 1]`.
  final double Function(double t)? press;

  /// Fewer layers and a coarser outline.
  final bool? simple;

  /// `{ ...this, ...over }`: the fields set in [over] win.
  StrokeOpts merge(StrokeOpts? over) {
    if (over == null) return this;
    return StrokeOpts(
      tier: over.tier ?? tier,
      wobble: over.wobble ?? wobble,
      speed: over.speed ?? speed,
      start: over.start ?? start,
      end: over.end ?? end,
      width: over.width ?? width,
      alpha: over.alpha ?? alpha,
      color: over.color ?? color,
      poly: over.poly ?? poly,
      round: over.round ?? round,
      raw: over.raw ?? raw,
      dry: over.dry ?? dry,
      press: over.press ?? press,
      simple: over.simple ?? simple,
    );
  }

  /// A copy with some fields set.
  StrokeOpts copyWith({
    Tier? tier,
    double? wobble,
    double? speed,
    StrokeStart? start,
    StrokeEnd? end,
    double? width,
    double? alpha,
    PaintKey? color,
    bool? poly,
    double? round,
    bool? raw,
    double? dry,
    double Function(double t)? press,
    bool? simple,
  }) => merge(
    StrokeOpts(
      tier: tier,
      wobble: wobble,
      speed: speed,
      start: start,
      end: end,
      width: width,
      alpha: alpha,
      color: color,
      poly: poly,
      round: round,
      raw: raw,
      dry: dry,
      press: press,
      simple: simple,
    ),
  );
}

/// A polyline to stroke, with its own options and pen.
///
/// Mirrors `Line` in `src/lib/ink/types.ts`.
final class Line {
  /// A line through [pts].
  const Line(this.pts, {this.o, this.pen});

  /// The points.
  final List<Pt> pts;

  /// Options for this line.
  final StrokeOpts? o;

  /// The pen for this line, over the caller's.
  final Pen? pen;
}

/// One filled outline of a stroke.
///
/// Mirrors `RibbonLayer` in `src/lib/ink/types.ts`.
final class RibbonLayer {
  /// A layer.
  const RibbonLayer({
    required this.k,
    required this.d,
    required this.fill,
    required this.op,
    this.evenOdd = false,
  });

  /// Which part of the stroke.
  final RibbonKind k;

  /// Path data.
  final String d;

  /// Paint.
  final PaintKey fill;

  /// Opacity.
  final double op;

  /// `fill-rule="evenodd"`.
  final bool evenOdd;
}

/// A drawn stroke: its layers, bounds, length and ends.
///
/// Mirrors `StrokeResult` in `src/lib/ink/types.ts`.
final class StrokeResult {
  /// A stroke.
  const StrokeResult({
    required this.kind,
    required this.layers,
    required this.bbox,
    required this.len,
    required this.start,
    required this.end,
  });

  final PenKind kind;
  final List<RibbonLayer> layers;
  final BBox bbox;
  final double len;
  final Pt start;
  final Pt end;
}
