import 'dart:math' as math;

/// How one side of a sheet is finished.
///
/// Mirrors `EdgeKind` in `src/lib/ink/paper/edges.ts`.
enum EdgeKind { cut, torn, deckle, crimp, zig, perf, scallop }

/// Every edge kind, in upstream order (`EDGE_KINDS`).
const List<EdgeKind> edgeKinds = EdgeKind.values;

/// A side of a sheet.
///
/// Mirrors `EdgeSide` in `src/lib/ink/paper/edges.ts`.
enum SheetSide { top, right, bottom, left }

/// The edge of each side of a sheet; unnamed sides are `cut`.
///
/// Mirrors `EdgeSpec` in `src/lib/ink/paper/edges.ts`: the string form is
/// [EdgeSpec.all], the per-side object form is the default constructor.
final class EdgeSpec {
  /// Per-side edges.
  const EdgeSpec({
    this.top = EdgeKind.cut,
    this.right = EdgeKind.cut,
    this.bottom = EdgeKind.cut,
    this.left = EdgeKind.cut,
  });

  /// The same edge on every side.
  const EdgeSpec.all(EdgeKind kind)
    : top = kind,
      right = kind,
      bottom = kind,
      left = kind;

  /// Top edge.
  final EdgeKind top;

  /// Right edge.
  final EdgeKind right;

  /// Bottom edge.
  final EdgeKind bottom;

  /// Left edge.
  final EdgeKind left;

  /// The edge of [side].
  EdgeKind of(SheetSide side) => switch (side) {
    SheetSide.top => top,
    SheetSide.right => right,
    SheetSide.bottom => bottom,
    SheetSide.left => left,
  };
}

/// The edges as `[top, right, bottom, left]`; null means all `cut`.
///
/// Mirrors `edgeSides` in `src/lib/ink/paper/edges.ts`.
List<EdgeKind> edgeSides(EdgeSpec? edge) {
  final spec = edge ?? const EdgeSpec();
  return [spec.top, spec.right, spec.bottom, spec.left];
}

/// Whether every side is `cut`.
///
/// Mirrors `isCutEdge` in `src/lib/ink/paper/edges.ts`.
bool isCutEdge(EdgeSpec? edge) =>
    edgeSides(edge).every((k) => k == EdgeKind.cut);

/// The first side that is not `cut`, or `cut`.
///
/// Mirrors `edgeName` in `src/lib/ink/paper/edges.ts`.
EdgeKind edgeName(EdgeSpec? edge) => edgeSides(
  edge,
).firstWhere((k) => k != EdgeKind.cut, orElse: () => EdgeKind.cut);

/// Zigzag pitch and depth (`ZIG`).
const ({double pitch, double depth}) zigEdge = (pitch: 8, depth: 4.2);

/// Perforation pitch and depth (`PERF`).
const ({double pitch, double depth}) perfEdge = (pitch: 5.4, depth: 2.3);

/// Scallop pitch (`SCALLOP`).
const double scallopPitch = 14;

/// How far the deepest edge reaches into the sheet, at least 0.6.
///
/// Mirrors `edgeInset` in `src/lib/ink/paper/edges.ts`.
double edgeInset(EdgeSpec? edge) {
  var m = 0.6;
  for (final kind in edgeSides(edge)) {
    final v = switch (kind) {
      EdgeKind.torn => 4.5,
      EdgeKind.deckle => 4.2,
      EdgeKind.crimp => 2.6,
      EdgeKind.zig => zigEdge.depth + 1,
      EdgeKind.perf => perfEdge.depth + 1,
      EdgeKind.scallop => scallopPitch * 0.4,
      EdgeKind.cut => 0.6,
    };
    m = math.max(m, v);
  }
  return m;
}
