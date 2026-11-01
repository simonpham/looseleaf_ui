import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/curves.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/xy_geometry.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';
import 'package:looseleaf_ink/src/charts/xy_stack.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// The XY plot's frame: what the mark passes share.
final class XYFrame {
  /// A frame.
  const XYFrame({
    required this.spec,
    required this.bucket,
    required this.horizontal,
    required this.scatter,
    required this.empty,
    required this.n,
    required this.band,
    required this.plotW,
    required this.catLen,
    required this.basePx,
    required this.vPos,
    required this.catPos,
    required this.xNum,
  });

  /// The chart.
  final XYSpec spec;

  /// Width class.
  final Bucket bucket;

  /// Sideways bars.
  final bool horizontal;

  /// A scatter chart.
  final bool scatter;

  /// Nothing to draw.
  final bool empty;

  /// Category count.
  final int n;

  /// Category pitch.
  final double band;

  /// Plot width.
  final double plotW;

  /// Category axis length.
  final double catLen;

  /// The zero line position.
  final double basePx;

  /// Value to position.
  final double Function(double v) vPos;

  /// Category to position.
  final double Function(int i) catPos;

  /// Scatter x to position.
  final double Function(double v) xNum;
}

/// Lays out the bars of [f]: grouped side by side, or stacked.
///
/// Mirrors the bars pass of `layoutXY` in `src/lib/ink/charts/chart-xy.ts`.
({List<XYBar> bars, double barW}) layoutBars(XYFrame f) {
  final spec = f.spec;
  final barSeries = [
    for (final (k, s) in spec.series.indexed)
      if (s.kind == XYKind.bar) (s: s, k: k),
  ];
  final ranges = stackRanges(
    [for (final e in barSeries) e.s],
    spec.stacked,
    f.n,
  );
  final m = switch (spec.stacked) {
    true => 1,
    false => math.max(1, barSeries.length),
  };
  final ratio = switch (f.bucket) {
    Bucket.sm => 0.72,
    Bucket.md => 0.66,
    Bucket.lg => 0.6,
  };
  final room = f.band * ratio;
  final gapCap = switch (f.bucket) {
    Bucket.sm => 2.0,
    _ => 3.0,
  };
  final gap = switch (m > 1) {
    true => math.max(0.0, math.min(gapCap, (room - m * 2.5) / (m - 1))),
    false => 0.0,
  };
  final barW = clampN((room - gap * (m - 1)) / m, 1, 58);
  final groupW = m * barW + gap * (m - 1);
  final bars = <XYBar>[];
  if (f.empty) return (bars: bars, barW: barW);
  for (final (bi, e) in barSeries.indexed) {
    for (var i = 0; i < f.n; i++) {
      final r = ranges[bi][i];
      if (r == null) continue;
      final c = f.catPos(i);
      final off = switch (spec.stacked) {
        true => 0,
        false => bi,
      };
      final a = c - groupW / 2 + off * (barW + gap);
      final lo = f.vPos(r.$1);
      final hi = f.vPos(r.$2);
      final v = e.s.values[i] ?? 0;
      bars.add(switch (f.horizontal) {
        true => XYBar(
          s: e.k,
          i: i,
          x: math.min(lo, hi),
          y: a,
          w: (hi - lo).abs(),
          h: barW,
          v: v,
          neg: v < 0,
        ),
        false => XYBar(
          s: e.k,
          i: i,
          x: a,
          y: math.min(lo, hi),
          w: barW,
          h: (hi - lo).abs(),
          v: v,
          neg: v < 0,
        ),
      });
    }
  }
  return (bars: bars, barW: barW);
}

List<List<Pt>> _sample(List<Pt?> pts, CurveKind curve) {
  final runs = <List<Pt>>[];
  var cur = <Pt>[];
  for (final p in pts) {
    if (p != null) {
      cur.add(p);
      continue;
    }
    if (cur.isNotEmpty) {
      runs.add(cur);
      cur = [];
    }
  }
  if (cur.isNotEmpty) runs.add(cur);
  return [
    for (final r in runs)
      switch ((r.length < 2, curve)) {
        (true, _) => r,
        (false, CurveKind.smooth) => monotoneCurve(r, 4),
        (false, CurveKind.step) => stepCurve(r),
        (false, CurveKind.linear) => r,
      },
  ];
}

/// Lays out lines and areas: points, thinned past one per 3 px, curved,
/// and area polygons down to the base or the stacked area below.
///
/// Mirrors the lines pass of `layoutXY` in `src/lib/ink/charts/chart-xy.ts`.
({List<XYLine> lines, List<XYArea> areas, int simplified}) layoutLines(
  XYFrame f,
) {
  final spec = f.spec;
  final n = f.n;
  final lines = <XYLine>[];
  final areas = <XYArea>[];
  var simplified = 0;
  final maxPts = math.max(24, JsMath.roundInt(f.plotW / 3));
  final lineSeries = [
    for (final (k, s) in spec.series.indexed)
      if (s.kind == XYKind.line || s.kind == XYKind.area) (s: s, k: k),
  ];
  final areaSeries = [
    for (final e in lineSeries)
      if (e.s.kind == XYKind.area) e,
  ];
  final areaRanges = stackRanges(
    [for (final e in areaSeries) e.s],
    spec.stacked,
    n,
  );
  if (f.empty || f.scatter) {
    return (lines: lines, areas: areas, simplified: simplified);
  }
  for (final e in lineSeries) {
    final ai = areaSeries.indexWhere((a) => a.k == e.k);
    final stackedArea = spec.stacked && ai >= 0;
    final pts = <Pt?>[];
    for (var i = 0; i < n; i++) {
      final v = e.s.values.elementAtOrNull(i);
      if (v == null || !isNum(v)) {
        pts.add(null);
        continue;
      }
      final range = switch (stackedArea) {
        true => areaRanges[ai][i],
        false => null,
      };
      final val = switch ((stackedArea, v < 0)) {
        (true, true) => range?.$1 ?? 0,
        (true, false) => range?.$2 ?? 0,
        _ => v,
      };
      pts.add((f.catPos(i), f.vPos(val)));
    }
    var use = pts;
    if (n > maxPts) {
      var last = 0.0;
      final filled = <Pt>[];
      for (final (i, p) in pts.indexed) {
        if (p != null) last = p.$2;
        filled.add((i.toDouble(), p?.$2 ?? last));
      }
      final keep = lttb(filled, maxPts).toSet();
      for (final (i, p) in pts.indexed) {
        if (p != null) continue;
        keep.add(i);
        if (i > 0) keep.add(i - 1);
        if (i < n - 1) keep.add(i + 1);
      }
      final order = keep.toList()..sort();
      use = [for (final i in order) pts[i]];
      simplified = math.max(simplified, n - order.length);
    }
    final segs = _sample(use, spec.curve);
    lines.add(XYLine(e.k, segs, pts));
    if (e.s.kind != XYKind.area) continue;
    final polys = <List<Pt>>[];
    for (final seg in segs) {
      if (seg.length < 2) continue;
      final base = <Pt>[(seg.last.$1, f.basePx), (seg.first.$1, f.basePx)];
      var lower = base;
      if (stackedArea && ai > 0) {
        final belowKey = areaSeries[ai - 1].k;
        final below = lines.where((l) => l.s == belowKey).firstOrNull;
        lower = switch (below) {
          final b? => [
            for (final p in _sample(b.pts, spec.curve).expand((s) => s))
              if (p.$1 >= seg.first.$1 - 0.01 && p.$1 <= seg.last.$1 + 0.01) p,
          ].reversed.toList(),
          null => <Pt>[],
        };
      }
      if (lower.isEmpty) lower = base;
      polys.add([...seg, ...lower]);
    }
    areas.add(XYArea(e.k, polys));
  }
  return (lines: lines, areas: areas, simplified: simplified);
}

/// Lays out point dots for lines, and the scatter points with their
/// targets.
///
/// Mirrors the dots pass of `layoutXY` in `src/lib/ink/charts/chart-xy.ts`.
({
  List<XYDot> dots,
  List<({int s, int j})> pointOf,
  List<double> tx,
  List<double> ty,
  int simplified,
})
layoutDots(XYFrame f, List<XYLine> lines) {
  final spec = f.spec;
  final n = f.n;
  final dots = <XYDot>[];
  final pointOf = <({int s, int j})>[];
  final tx = <double>[];
  final ty = <double>[];
  var simplified = 0;
  final lineCount = lines.length;
  final autoDots =
      spec.dots == null &&
      n <= 24 &&
      f.catLen / math.max(1, n) >= 15 &&
      lineCount <= 4;
  final showDots =
      !f.scatter && lineCount > 0 && (spec.dots == true || autoDots);
  if (showDots) {
    for (final l in lines) {
      final ser = spec.series[l.s];
      if (ser.kind == XYKind.area && spec.dots == null && lineCount > 1) {
        continue;
      }
      for (final (i, p) in l.pts.indexed) {
        if (p == null) continue;
        dots.add(
          XYDot(s: l.s, i: i, x: p.$1, y: p.$2, r: 3.4, last: i == n - 1),
        );
      }
    }
  }
  if (f.scatter && !f.empty) {
    const maxPoints = 600;
    for (final (k, ser) in spec.series.indexed) {
      final xs = ser.xs;
      if (ser.kind != XYKind.scatter || xs == null) continue;
      final cnt = math.min(ser.values.length, xs.length);
      final stride = math.max(
        1,
        (cnt / (maxPoints / math.max(1, spec.series.length))).ceil(),
      );
      final smax = (ser.sizes ?? const <double>[])
          .where(isNum)
          .fold(1.0, math.max);
      if (stride > 1) {
        simplified = math.max(simplified, cnt - (cnt / stride).ceil());
      }
      for (var j = 0; j < cnt; j += stride) {
        final yv = ser.values[j];
        final xv = xs[j];
        if (yv == null || !isNum(yv) || !isNum(xv)) continue;
        final sz = ser.sizes?.elementAtOrNull(j);
        final r = switch (sz) {
          final size? when isNum(size) =>
            3 + 9 * JsMath.sqrt(math.max(0, size) / smax),
          _ => 4.2,
        };
        final px = f.xNum(xv);
        final py = f.vPos(yv);
        dots.add(XYDot(s: k, i: j, x: px, y: py, r: r, last: false));
        pointOf.add((s: k, j: j));
        tx.add(px);
        ty.add(py);
      }
    }
  }
  return (
    dots: dots,
    pointOf: pointOf,
    tx: tx,
    ty: ty,
    simplified: simplified,
  );
}
