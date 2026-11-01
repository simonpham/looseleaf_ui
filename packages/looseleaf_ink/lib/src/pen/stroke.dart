import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Strokes [pointsIn] with a pen. One point draws a [dot]; none draws nothing.
///
/// Mirrors `stroke` in `src/lib/ink/pen.ts`.
StrokeResult stroke(
  List<Pt> pointsIn,
  Pen penIn,
  Rng rng, [
  StrokeOpts o = const StrokeOpts(),
]) {
  final p = penIn.spec;
  final tier = o.tier ?? Tier.lo;
  final cfg = tierCfg(tier);
  final pts = [
    for (final pt in pointsIn)
      if (pt.x.isFinite && pt.y.isFinite)
        (clamp(pt.x, -1e5, 1e5), clamp(pt.y, -1e5, 1e5)),
  ];
  if (pts.isEmpty) {
    return StrokeResult(
      kind: p.kind,
      layers: const [],
      bbox: BBox(0, 0, 0, 0),
      len: 0,
      start: (0, 0),
      end: (0, 0),
    );
  }
  if (pts.length < 2) return dot(pts[0].x, pts[0].y, p.w * 0.6, p, rng, o);
  final lo = tier == Tier.lo;
  return switch (p.kind) {
    PenKind.marker || PenKind.hl => markerStroke(pts, p, rng, o, cfg, lo),
    _ => lineStroke(pts, p, rng, o, cfg, lo),
  };
}

/// A blot of ink at `(cx, cy)`.
///
/// Mirrors `dot` in `src/lib/ink/pen.ts`.
StrokeResult dot(
  double cx,
  double cy,
  double r,
  Pen penIn,
  Rng rng, [
  StrokeOpts o = const StrokeOpts(),
]) {
  final p = penIn.spec;
  final tier = o.tier ?? Tier.lo;
  final sink = Sink(tierCfg(tier));
  final rl = rng.fork('dot');
  final color = o.color ?? p.color;
  final layers = <RibbonLayer>[];
  final rr = r * (o.width ?? 1);
  final hi = tier == Tier.hi;
  if (p.kind == PenKind.felt) {
    if (p.halo > 0 && hi) {
      layers.add(
        RibbonLayer(
          k: RibbonKind.halo,
          d: sink.poly(blobPts(cx, cy, rr + p.bleed * 1.4, 0.2, rl.call, 12)),
          fill: color,
          op: p.halo * 0.9,
        ),
      );
    }
    layers
      ..add(
        RibbonLayer(
          k: RibbonKind.body,
          d: sink.poly(blobPts(cx, cy, rr, 0.09, rl.call, 11)),
          fill: color,
          op: p.alpha * (o.alpha ?? 1),
        ),
      )
      ..add(
        RibbonLayer(
          k: RibbonKind.pool,
          d: sink.poly(blobPts(cx + rr * 0.05, cy, rr * 0.7, 0.1, rl.call, 9)),
          fill: color,
          op: p.core,
        ),
      );
    return _dotResult(PenKind.felt, layers, sink, cx, cy);
  }
  if (hi) {
    layers.add(
      RibbonLayer(
        k: RibbonKind.smear,
        d: sink.poly(blobPts(cx, cy, rr * 1.15, 0.1, rl.call, 10)),
        fill: color,
        op: JsMath.or(p.smear, 0.2),
      ),
    );
  }
  layers.add(
    RibbonLayer(
      k: RibbonKind.body,
      d: sink.poly(blobPts(cx, cy, rr, 0.12, rl.call, 10)),
      fill: color,
      op: p.alpha * (o.alpha ?? 1),
    ),
  );
  final kind = switch (p.kind) {
    PenKind.hl || PenKind.marker => PenKind.felt,
    final other => other,
  };
  return _dotResult(kind, layers, sink, cx, cy);
}

StrokeResult _dotResult(
  PenKind kind,
  List<RibbonLayer> layers,
  Sink sink,
  double cx,
  double cy,
) => StrokeResult(
  kind: kind,
  layers: layers,
  bbox: sink.bb,
  len: 0,
  end: (cx, cy),
  start: (cx, cy),
);
