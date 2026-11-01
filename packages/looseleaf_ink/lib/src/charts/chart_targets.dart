import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';

/// How pointer and keys find a target.
enum TargetMode { x, y, point, sector, cell }

/// How arrow keys move between targets.
enum TargetNav { linear, grid }

/// Sector hit areas: per target radii and angles around a centre.
final class SectorTargets {
  /// Sectors.
  const SectorTargets({
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

  /// Inner radius per target.
  final List<double> r0;

  /// Outer radius per target.
  final List<double> r1;

  /// Start angle per target (radians, clockwise from 12 o'clock).
  final List<double> a0;

  /// End angle per target.
  final List<double> a1;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'cx': cx,
    'cy': cy,
    'r0': r0,
    'r1': r1,
    'a0': a0,
    'a1': a1,
  };
}

/// Grid cell hit areas.
final class CellTargets {
  /// Cells.
  const CellTargets({
    required this.x0,
    required this.y0,
    required this.cw,
    required this.ch,
    required this.cols,
    required this.rows,
    required this.index,
  });

  /// Grid left.
  final double x0;

  /// Grid top.
  final double y0;

  /// Cell pitch, horizontal.
  final double cw;

  /// Cell pitch, vertical.
  final double ch;

  /// Columns.
  final int cols;

  /// Rows.
  final int rows;

  /// Per cell, its own index, or -1 for a gap.
  final List<int> index;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'x0': x0,
    'y0': y0,
    'cw': cw,
    'ch': ch,
    'cols': cols,
    'rows': rows,
    'index': index,
  };
}

/// What pointer and keyboard can land on, and where.
///
/// Mirrors `ChartTargets` in `src/lib/ink/charts/chart-types.ts`.
final class ChartTargets {
  /// Targets.
  const ChartTargets({
    required this.n,
    required this.mode,
    required this.cx,
    required this.cy,
    required this.nav,
    this.pos,
    this.cols,
    this.sector,
    this.cells,
  });

  /// How many.
  final int n;

  /// How they are hit.
  final TargetMode mode;

  /// Their position along the axis (`x` and `y` modes).
  final List<double>? pos;

  /// Tooltip anchor x per target.
  final List<double> cx;

  /// Tooltip anchor y per target.
  final List<double> cy;

  /// Key navigation.
  final TargetNav nav;

  /// Grid columns.
  final int? cols;

  /// Sector geometry.
  final SectorTargets? sector;

  /// Cell geometry.
  final CellTargets? cells;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'n': n,
    'mode': mode.name,
    'pos': pos,
    'cx': cx,
    'cy': cy,
    'nav': nav.name,
    'cols': cols,
    'sector': sector?.toJson(),
    'cells': cells?.toJson(),
  };
}

/// What a cursor highlight draws.
enum CursorKind { column, guide, ring, slice, cell, spoke }

/// A cursor highlight: a box, plus a slot for rings, slice geometry or a
/// spoke, relative to the box.
///
/// Mirrors `CursorSpec` in `src/lib/ink/charts/chart-types.ts`.
final class CursorSpec {
  /// A cursor.
  const CursorSpec({
    required this.kind,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.slot,
    this.cx,
    this.cy,
    this.r0,
    this.r1,
    this.a0,
    this.a1,
    this.x1,
    this.y1,
    this.x2,
    this.y2,
  });

  /// The kind.
  final CursorKind kind;

  /// Box left.
  final double x;

  /// Box top.
  final double y;

  /// Box width.
  final double w;

  /// Box height.
  final double h;

  /// Series slot of a ring.
  final int? slot;

  /// Slice centre x, in the box.
  final double? cx;

  /// Slice centre y, in the box.
  final double? cy;

  /// Slice inner radius.
  final double? r0;

  /// Slice outer radius.
  final double? r1;

  /// Slice start angle.
  final double? a0;

  /// Slice end angle.
  final double? a1;

  /// Spoke start x, in the box.
  final double? x1;

  /// Spoke start y, in the box.
  final double? y1;

  /// Spoke end x, in the box.
  final double? x2;

  /// Spoke end y, in the box.
  final double? y2;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'slot': slot,
    'cx': cx,
    'cy': cy,
    'r0': r0,
    'r1': r1,
    'a0': a0,
    'a1': a1,
    'x1': x1,
    'y1': y1,
    'x2': x2,
    'y2': y2,
  };
}

/// The cursor highlights for target [i], optionally one [series] only.
typedef CursorAt = List<CursorSpec> Function(int i, [int? series]);

/// What every chart layout has: size, bucket, labels, targets and cursors.
///
/// Mirrors `ChartLayoutBase` in `src/lib/ink/charts/chart-types.ts`.
abstract base class ChartLayoutBase {
  /// A layout.
  const ChartLayoutBase({
    required this.w,
    required this.h,
    required this.bucket,
    required this.labels,
    required this.targets,
    required this.cursorAt,
  });

  /// Width.
  final double w;

  /// Height.
  final double h;

  /// Width class.
  final Bucket bucket;

  /// Text labels.
  final List<ChartLabel> labels;

  /// Pointer and keyboard targets.
  final ChartTargets targets;

  /// Cursor highlights per target.
  final CursorAt cursorAt;

  /// The upstream JSON shape (without [cursorAt]).
  Map<String, Object?> toJson() => {
    'w': w,
    'h': h,
    'bucket': bucket.name,
    'labels': [for (final l in labels) l.toJson()],
    'targets': targets.toJson(),
  };
}
