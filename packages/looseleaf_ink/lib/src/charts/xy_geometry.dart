import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';
import 'package:looseleaf_ink/src/core/core.dart';

List<double>? _pt(Pt? p) => switch (p) {
  (final x, final y) => [x, y],
  null => null,
};

List<List<double>?> _pts(List<Pt?> pts) => [for (final p in pts) _pt(p)];

/// A bar: series [s], category [i], its rectangle and value.
///
/// Mirrors `XYBar` in `src/lib/ink/charts/chart-xy.ts`.
final class XYBar {
  /// A bar.
  const XYBar({
    required this.s,
    required this.i,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.v,
    required this.neg,
  });

  /// Series index.
  final int s;

  /// Category index.
  final int i;

  /// Left.
  final double x;

  /// Top.
  final double y;

  /// Width.
  final double w;

  /// Height.
  final double h;

  /// The value.
  final double v;

  /// Whether the value is negative.
  final bool neg;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    's': s,
    'i': i,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'v': v,
    'neg': neg,
  };
}

/// A line: its drawn segments and one point per category.
///
/// Mirrors `XYLine` in `src/lib/ink/charts/chart-xy.ts`.
final class XYLine {
  /// A line.
  const XYLine(this.s, this.segs, this.pts);

  /// Series index.
  final int s;

  /// The drawn runs, curved.
  final List<List<Pt>> segs;

  /// One point per category (null for a gap).
  final List<Pt?> pts;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    's': s,
    'segs': [for (final seg in segs) _pts(seg)],
    'pts': _pts(pts),
  };
}

/// An area: its filled polygons.
///
/// Mirrors `XYArea` in `src/lib/ink/charts/chart-xy.ts`.
final class XYArea {
  /// An area.
  const XYArea(this.s, this.polys);

  /// Series index.
  final int s;

  /// The polygons, one per run.
  final List<List<Pt>> polys;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    's': s,
    'polys': [for (final p in polys) _pts(p)],
  };
}

/// A point dot.
///
/// Mirrors `XYDot` in `src/lib/ink/charts/chart-xy.ts`.
final class XYDot {
  /// A dot.
  const XYDot({
    required this.s,
    required this.i,
    required this.x,
    required this.y,
    required this.r,
    required this.last,
  });

  /// Series index.
  final int s;

  /// Category (or point) index.
  final int i;

  /// Centre x.
  final double x;

  /// Centre y.
  final double y;

  /// Radius.
  final double r;

  /// Whether it is the last category.
  final bool last;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    's': s,
    'i': i,
    'x': x,
    'y': y,
    'r': r,
    'last': last,
  };
}

/// An annotation's marks: a loop or underline and an arrow.
///
/// Mirrors `XYNoteGeom` in `src/lib/ink/charts/chart-xy.ts`.
final class XYNoteGeom {
  /// A note.
  const XYNoteGeom({
    required this.n,
    required this.pen,
    required this.shape,
    required this.loop,
    required this.underline,
    required this.arrow,
  });

  /// Note index.
  final int n;

  /// The pen.
  final NotePen pen;

  /// How the point is marked.
  final NoteShape shape;

  /// The loop around the point.
  final ({double cx, double cy, double rx, double ry})? loop;

  /// The underline under the text.
  final ({double x1, double x2, double y})? underline;

  /// The arrow from the text to the point.
  final ({double x1, double y1, double x2, double y2})? arrow;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'n': n,
    'pen': pen.name,
    'shape': shape.name,
    'loop': switch (loop) {
      final l? => {'cx': l.cx, 'cy': l.cy, 'rx': l.rx, 'ry': l.ry},
      null => null,
    },
    'underline': switch (underline) {
      final u? => {'x1': u.x1, 'x2': u.x2, 'y': u.y},
      null => null,
    },
    'arrow': switch (arrow) {
      final a? => {'x1': a.x1, 'y1': a.y1, 'x2': a.x2, 'y2': a.y2},
      null => null,
    },
  };
}

/// A rectangle (band shading).
typedef XYRect = ({double x, double y, double w, double h});

/// A reference line segment.
///
/// Mirrors `XYRefGeom` in `src/lib/ink/charts/chart-xy.ts`.
typedef XYRefGeom = ({double x1, double y1, double x2, double y2, NotePen pen});

/// A laid out XY chart.
///
/// Mirrors `XYLayout` in `src/lib/ink/charts/chart-xy.ts`.
final class XYLayout extends ChartLayoutBase {
  /// A layout.
  const XYLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.plot,
    required this.horizontal,
    required this.band,
    required this.gridPx,
    required this.basePx,
    required this.bars,
    required this.lines,
    required this.areas,
    required this.dots,
    required this.notes,
    required this.refs,
    required this.bands,
    required this.barW,
    required this.pointOf,
    required this.simplified,
  });

  /// The plot area.
  final ({double x0, double y0, double x1, double y1}) plot;

  /// Whether bars run sideways.
  final bool horizontal;

  /// The category pitch.
  final double band;

  /// Gridline positions.
  final List<double> gridPx;

  /// The zero line position.
  final double basePx;

  /// Bars.
  final List<XYBar> bars;

  /// Lines (and area outlines).
  final List<XYLine> lines;

  /// Area fills.
  final List<XYArea> areas;

  /// Dots.
  final List<XYDot> dots;

  /// Annotation marks.
  final List<XYNoteGeom> notes;

  /// Reference lines.
  final List<XYRefGeom> refs;

  /// Band shading.
  final List<XYRect> bands;

  /// Bar width.
  final double barW;

  /// Scatter target to `(series, point)`.
  final List<({int s, int j})> pointOf;

  /// How many points were dropped to keep the drawing readable.
  final int simplified;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'plot': {'x0': plot.x0, 'y0': plot.y0, 'x1': plot.x1, 'y1': plot.y1},
    'horizontal': horizontal,
    'band': band,
    'gridPx': gridPx,
    'basePx': basePx,
    'bars': [for (final b in bars) b.toJson()],
    'lines': [for (final l in lines) l.toJson()],
    'areas': [for (final a in areas) a.toJson()],
    'dots': [for (final d in dots) d.toJson()],
    'notes': [for (final n in notes) n.toJson()],
    'refs': [
      for (final r in refs)
        {'x1': r.x1, 'y1': r.y1, 'x2': r.x2, 'y2': r.y2, 'pen': r.pen.name},
    ],
    'bands': [
      for (final b in bands) {'x': b.x, 'y': b.y, 'w': b.w, 'h': b.h},
    ],
    'barW': barW,
    'pointOf': [
      for (final p in pointOf) {'s': p.s, 'j': p.j},
    ],
    'simplified': simplified,
  };
}
