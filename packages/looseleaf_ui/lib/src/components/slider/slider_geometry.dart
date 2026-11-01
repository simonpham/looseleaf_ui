import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Where a [Slider]'s values sit along its track, from upstream
/// `src/components/ui/slider.tsx` (`THUMB`, `fillWindow`, `tickIntervals`).
class SliderGeometry {
  const SliderGeometry({
    required this.length,
    required this.min,
    required this.max,
    required this.step,
    required this.startsLow,
  });

  /// `THUMB`: the thumb's side, which the track keeps clear at its ends.
  static const double thumb = Spacing.d20;

  /// The track's length along the axis.
  final double length;
  final double min;
  final double max;
  final double step;

  /// Whether [min] is at the start of the axis: the left, or the top of a
  /// vertical slider.
  final bool startsLow;

  double get _span => switch (max - min) {
    0 => 1,
    final span => span,
  };

  /// [value] as a fraction of the range, clamped to 0..1.
  double fraction(double value) => ((value - min) / _span).clamp(0, 1);

  /// The offset along the axis, from the left or top, of a point
  /// [fraction] of the way from [min], with the thumb's half kept clear
  /// when [thumbAligned] (upstream `at(pct, thumb)`).
  double offsetOf(double fraction, {bool thumbAligned = true}) {
    final inset = switch (thumbAligned) {
      true => thumb,
      false => 0.0,
    };
    final fromLow = inset / 2 + (length - inset) * fraction;
    return switch (startsLow) {
      true => fromLow,
      false => length - fromLow,
    };
  }

  /// The value under [offset] along the axis, snapped to [step].
  double valueAt(double offset) {
    final usable = math.max(1.0, length - thumb);
    final fromLow = switch (startsLow) {
      true => offset,
      false => length - offset,
    };
    final fraction = ((fromLow - thumb / 2) / usable).clamp(0.0, 1.0);
    return snap(min + fraction * _span);
  }

  /// [value] on the step grid, inside [min]..[max].
  double snap(double value) {
    final steps = ((value - min) / step).round();
    final snapped = min + steps * step;
    final decimals = _decimals(step);
    final rounded = double.parse(snapped.toStringAsFixed(decimals));
    return rounded.clamp(min, max);
  }

  static int _decimals(double step) {
    final text = step.toString();
    final dot = text.indexOf('.');
    if (dot < 0 || text.endsWith('.0')) return 0;
    return text.length - dot - 1;
  }

  /// The filled stretch, from the low thumb (or the track's start for a
  /// single value) to the high one, as a range along the axis.
  (double, double) fill(List<double> values) {
    final fractions = [for (final value in values) fraction(value)];
    final multi = fractions.length > 1;
    final from = switch (multi) {
      true => fractions.reduce(math.min),
      false => 0.0,
    };
    final to = switch (fractions.isEmpty) {
      true => 0.0,
      false => fractions.reduce(math.max),
    };
    final a = offsetOf(from, thumbAligned: multi);
    final b = offsetOf(to);
    return (math.min(a, b), math.max(a, b));
  }

  /// Upstream `tickIntervals`: [count] when given (at most 200), else one
  /// per step when that makes 1 to 20, else 10; 0 without ticks.
  static int tickIntervals({
    required bool ticks,
    int? count,
    required double min,
    required double max,
    required double step,
  }) {
    if (count case final intervals?) return intervals.clamp(0, 200);
    if (!ticks) return 0;
    final steps = ((max - min) / step).round();
    if (steps >= 1 && steps <= 20) return steps;
    return 10;
  }
}

/// Clips the fill to the stretch between [from] and [to] along [axis],
/// reaching [overhang] past the track across it.
class SliderFillClipper extends CustomClipper<Rect> {
  const SliderFillClipper({
    required this.axis,
    required this.from,
    required this.to,
    this.overhang = Spacing.d12,
  });

  final Axis axis;
  final double from;
  final double to;
  final double overhang;

  @override
  Rect getClip(Size size) => switch (axis) {
    Axis.horizontal => Rect.fromLTRB(
      from,
      -overhang,
      to,
      size.height + overhang,
    ),
    Axis.vertical => Rect.fromLTRB(-overhang, from, size.width + overhang, to),
  };

  @override
  bool shouldReclip(SliderFillClipper oldClipper) =>
      oldClipper.axis != axis ||
      oldClipper.from != from ||
      oldClipper.to != to ||
      oldClipper.overhang != overhang;
}
