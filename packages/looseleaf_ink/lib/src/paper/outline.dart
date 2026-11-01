import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/edge_samples.dart';
import 'package:looseleaf_ink/src/paper/edges.dart';

/// The run of outline points drawn with one edge kind.
///
/// Mirrors `Outline['sides']` in `src/lib/ink/paper/edges.ts`.
final class OutlineSide {
  /// A side spanning points `[from, to)`.
  const OutlineSide(this.kind, this.from, this.to);

  /// The edge kind.
  final EdgeKind kind;

  /// First point index.
  final int from;

  /// One past the last point index.
  final int to;
}

/// A sheet's outline: the body edge, the fibre rim just outside it, and
/// how it should be drawn.
///
/// Mirrors `Outline` in `src/lib/ink/paper/edges.ts`.
final class Outline {
  /// An outline.
  const Outline({
    required this.pts,
    required this.rim,
    required this.crisp,
    required this.reach,
    required this.fibrous,
    required this.sides,
  });

  /// The body edge, clockwise from the top left.
  final List<Pt> pts;

  /// The fibre rim, one point per body point.
  final List<Pt> rim;

  /// Whether a side is zigzag, perforated or scalloped (drawn with straight
  /// segments).
  final bool crisp;

  /// The farthest fibre reach.
  final double reach;

  /// Whether a side is torn or deckled.
  final bool fibrous;

  /// The point runs per side; empty once a corner is chamfered.
  final List<OutlineSide> sides;
}

/// Which ring of an [Outline] to draw.
enum OutlineRing { body, rim }

/// Traces a [w]×[h] sheet with [edge] on each side; [chamfer] cuts the
/// bottom-right corner.
///
/// Mirrors `sheetOutline` in `src/lib/ink/paper/edges.ts`.
Outline sheetOutline(
  Rng rng,
  double w,
  double h,
  EdgeSpec? edge, {
  double? amp,
  double? chamfer,
}) {
  final a = amp ?? 1;
  final kinds = edgeSides(edge);
  final top = edgeSamples(kinds[0], w, rng.fork('top'), a);
  final right = edgeSamples(kinds[1], h, rng.fork('right'), a);
  final bottom = edgeSamples(kinds[2], w, rng.fork('bottom'), a);
  final left = edgeSamples(kinds[3], h, rng.fork('left'), a);
  final pts = <Pt>[];
  final rim = <Pt>[];
  var reach = 0.0;
  void push(Pt p, Pt r, double f) {
    pts.add(p);
    rim.add(r);
    if (f > reach) reach = f;
  }

  final sides = <OutlineSide>[];
  void mark(EdgeKind kind, int from) =>
      sides.add(OutlineSide(kind, from, pts.length));
  for (final q in top) {
    push((q.u, q.e), (q.u, q.e - q.f), q.f);
  }
  mark(kinds[0], 0);
  for (final q in right) {
    push((w - q.e, q.u), (w - q.e + q.f, q.u), q.f);
  }
  mark(kinds[1], sides[0].to);
  for (final q in bottom) {
    push((w - q.u, h - q.e), (w - q.u, h - q.e + q.f), q.f);
  }
  mark(kinds[2], sides[1].to);
  for (final q in left) {
    push((q.e, h - q.u), (q.e - q.f, h - q.u), q.f);
  }
  mark(kinds[3], sides[2].to);
  if (chamfer case final c? when c > 0) {
    _chamferCorner(pts, rim, w, h, c);
    sides.clear();
  }
  final crisp = kinds.any(
    (k) => k == EdgeKind.zig || k == EdgeKind.perf || k == EdgeKind.scallop,
  );
  final fibrous = kinds.any(
    (k) => k == EdgeKind.torn || k == EdgeKind.deckle,
  );
  return Outline(
    pts: pts,
    rim: rim,
    crisp: crisp,
    reach: reach,
    fibrous: fibrous,
    sides: sides,
  );
}

void _chamferCorner(List<Pt> pts, List<Pt> rim, double w, double h, double c) {
  for (var i = pts.length - 1; i >= 0; i--) {
    final p = pts[i];
    if (p.x > w - c - 0.5 && p.y > h - c - 0.5 && p.x + p.y > w + h - c) {
      pts.removeAt(i);
      rim.removeAt(i);
    }
  }
  var at = -1;
  for (var i = 1; i < pts.length; i++) {
    final p = pts[i];
    if (p.y > h - 2 && p.x < w - c && pts[i - 1].x > p.x) {
      at = i;
      break;
    }
  }
  final ins = <Pt>[(w - 0.3, h - c), (w - c, h - 0.3)];
  final j = switch (at < 0) {
    true => pts.length,
    false => at,
  };
  pts.insertAll(j, ins);
  rim.insertAll(j, ins);
}

/// The path of the body or rim of [o] at [tier].
///
/// Mirrors `outlinePath` in `src/lib/ink/paper/edges.ts`.
String outlinePath(Outline o, OutlineRing which, [Tier tier = Tier.lo]) {
  final pts = switch (which) {
    OutlineRing.body => o.pts,
    OutlineRing.rim => o.rim,
  };
  final cfg = tierCfg(tier);
  if (o.crisp) {
    return switch (which) {
      OutlineRing.body => simplePath(pts, cfg.withTol(cfg.tol * 0.8)),
      OutlineRing.rim => polyPath(pts, 10),
    };
  }
  return smoothClosed(pts, cfg.withTol(cfg.tol * 1.75));
}

/// The mean inset of each side, `[top, right, bottom, left]`, to 0.1 px.
///
/// Mirrors `sideInsets` in `src/lib/ink/paper/edges.ts`.
List<double> sideInsets(Outline o, double w, double h, [double chamfer = 0]) {
  final sum = [0.0, 0.0, 0.0, 0.0];
  final cnt = [0, 0, 0, 0];
  for (final (x, y) in o.pts) {
    if (chamfer != 0 && x > w - chamfer - 1 && y > h - chamfer - 1) continue;
    final d = [y, w - x, h - y, x];
    var k = 0;
    for (var i = 1; i < 4; i++) {
      if (d[i] < d[k]) k = i;
    }
    sum[k] += d[k];
    cnt[k]++;
  }
  return [
    for (var i = 0; i < 4; i++)
      JsMath.round(
            switch (cnt[i]) {
                  0 => 0.5,
                  final count => sum[i] / count,
                } *
                10,
          ) /
          10,
  ];
}
