import 'package:looseleaf_ink/src/charts/charts.dart';

/// What the small chart mark ([chartMarkRecipe]) draws: a legend swatch,
/// or one of the cursor highlights.
///
/// Mirrors `MiniParams` in `src/lib/ink/charts/chart-types.ts`.
sealed class MiniParams {
  const MiniParams();

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson();
}

/// A legend swatch for series [slot]: a filled square with its [pattern],
/// or with [line] a short stroke in [dash] with its [marker].
final class MiniSwatch extends MiniParams {
  /// A swatch.
  const MiniSwatch({
    required this.slot,
    required this.pattern,
    this.marker,
    this.line,
    this.dash,
  });

  /// The series slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The point marker of a line swatch.
  final MarkerShape? marker;

  /// Draws a line instead of a square.
  final bool? line;

  /// The line's dash.
  final Dash? dash;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'swatch',
    'slot': slot,
    'pattern': pattern.name,
    'marker': ?marker?.name,
    'line': ?line,
    'dash': ?dash?.name,
  };
}

/// A highlighter swipe over a hovered column (or row, when wider than
/// tall).
final class MiniColumn extends MiniParams {
  /// A column cursor.
  const MiniColumn({this.slot});

  /// Unused by the drawing; kept for upstream's key.
  final int? slot;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'column',
    'slot': ?slot,
  };
}

/// A dashed pencil guide down a hovered x.
final class MiniGuide extends MiniParams {
  /// A guide cursor.
  const MiniGuide({this.slot});

  /// Unused by the drawing; kept for upstream's key.
  final int? slot;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'guide',
    'slot': ?slot,
  };
}

/// A highlighted, outlined heatmap cell.
final class MiniCell extends MiniParams {
  /// A cell cursor.
  const MiniCell({this.slot});

  /// Unused by the drawing; kept for upstream's key.
  final int? slot;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'cell',
    'slot': ?slot,
  };
}

/// An inked ring around a hovered point of series [slot].
final class MiniRing extends MiniParams {
  /// A ring cursor.
  const MiniRing({required this.slot});

  /// The series slot.
  final int slot;

  @override
  Map<String, Object?> toJson() => {'kind': 'ring', 'slot': slot};
}

/// A highlighted, outlined pie or radial sector, centred at [cx], [cy]
/// from radius [r0] to [r1] and angle [a0] to [a1] (radians, clockwise
/// from twelve o'clock).
final class MiniSlice extends MiniParams {
  /// A slice cursor.
  const MiniSlice({
    required this.cx,
    required this.cy,
    required this.r0,
    required this.r1,
    required this.a0,
    required this.a1,
  });

  /// Centre x.
  final double cx;

  /// Centre y.
  final double cy;

  /// Inner radius.
  final double r0;

  /// Outer radius.
  final double r1;

  /// Start angle.
  final double a0;

  /// End angle.
  final double a1;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'slice',
    'cx': cx,
    'cy': cy,
    'r0': r0,
    'r1': r1,
    'a0': a0,
    'a1': a1,
  };
}

/// A highlighter stroke along a radar spoke from [x1], [y1] to [x2], [y2].
final class MiniSpoke extends MiniParams {
  /// A spoke cursor.
  const MiniSpoke({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  /// Start x.
  final double x1;

  /// Start y.
  final double y1;

  /// End x.
  final double x2;

  /// End y.
  final double y2;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'spoke',
    'x1': x1,
    'y1': y1,
    'x2': x2,
    'y2': y2,
  };
}
