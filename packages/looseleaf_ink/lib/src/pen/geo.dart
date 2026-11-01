import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

typedef Noise = double Function(double s);

/// A stroke's resampled spine: positions, tangents, normals, turning,
/// velocity and the noise fields the pens read.
///
/// Mirrors `Geo` in `src/lib/ink/pen.ts`.
final class Geo {
  Geo({
    required this.x,
    required this.y,
    required this.s,
    required this.tx,
    required this.ty,
    required this.nx,
    required this.ny,
    required this.th,
    required this.turn,
    required this.v,
    required this.length,
    required this.n,
    required this.seg,
    required this.nW9,
    required this.nP40,
    required this.nDry,
    required this.nFlow,
    required this.nDens,
    required this.nTooth,
    required this.nGap,
    required this.endMode,
    required this.startMode,
    required this.capN,
  });

  final Float64List x, y, s, tx, ty, nx, ny, th, turn, v;
  final double length;
  final int n;
  final double seg;
  final Noise nW9, nP40, nDry, nFlow, nDens, nTooth, nGap;
  final StrokeEnd endMode;
  final StrokeStart startMode;
  final int capN;
}

double _wrap(double a) {
  if (a > JsMath.pi) return a - tau;
  if (a < -JsMath.pi) return a + tau;
  return a;
}

/// Resamples and wobbles [pts] and measures everything a pen needs.
///
/// Mirrors `prepare` in `src/lib/ink/pen.ts`.
Geo prepare(List<Pt> pts, PenSpec p, Rng rng, StrokeOpts o, TierCfg cfg) {
  final simple = o.simple ?? false;
  var raw = 0.0;
  for (var i = 1; i < pts.length; i++) {
    raw += JsMath.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y);
  }
  final simpleK = switch (simple) {
    true => 1.8,
    false => 1.0,
  };
  final step0 = math.max(p.step * cfg.stepK * simpleK, raw / 6000);
  final round = o.round ?? 0;
  final filleted = switch (round != 0 && !round.isNaN) {
    true => fillet(pts, round),
    false => pts,
  };
  final dense = switch (o.poly ?? false) {
    true => densify(filleted, step0),
    false => spline(pts, step0),
  };
  var l0 = 0.0;
  for (var i = 1; i < dense.length; i++) {
    l0 += JsMath.hypot(
      dense[i].x - dense[i - 1].x,
      dense[i].y - dense[i - 1].y,
    );
  }
  final step = switch (l0 < 30) {
    true => math.max(0.7, math.min(step0, l0 / 22)),
    false => step0,
  };
  final sampled = resample(dense, step);
  final x = sampled.x, y = sampled.y, s = sampled.s, length = sampled.length;
  final n = x.length;
  final rn = rng.fork('noise');
  final nLow = noise1(rn, length, p.wob.wl),
      nMid = noise1(rn, length, p.wob.wl * 0.3),
      nTr = noise1(rn, length, 4.5);
  final nW9 = noise1(rn, length, 9), nP40 = noise1(rn, length, 40);
  final nDry = noise1(rn, length, 26), nFlow = noise1(rn, length, 18);
  final r2 = rng.fork('noise2');
  final nDens = noise1(r2, length, 55),
      nTooth = noise1(r2, length, p.dryWl),
      nGap = noise1(r2, length, 9);
  final wob = switch (o.raw ?? false) {
    true => 0.0,
    false => o.wobble ?? 1,
  };
  if (wob > 0 && n > 2) {
    final amp = p.wob.amp * wob * clamp(length / 120, 0.2, 1.4);
    final tr = p.wob.tr * wob;
    final dx = Float64List(n), dy = Float64List(n);
    for (var i = 0; i < n; i++) {
      final a = math.max(0, i - 1), b = math.min(n - 1, i + 1);
      final tx = x[b] - x[a], ty = y[b] - y[a];
      final l = JsMath.or(JsMath.hypot(tx, ty), 1);
      final off = amp * (nLow(s[i]) + 0.3 * nMid(s[i])) + tr * nTr(s[i]);
      dx[i] = (ty / l) * off;
      dy[i] = (-tx / l) * off;
    }
    for (var i = 0; i < n; i++) {
      x[i] += dx[i];
      y[i] += dy[i];
    }
  }
  final tx = Float64List(n),
      ty = Float64List(n),
      nx = Float64List(n),
      ny = Float64List(n);
  final th = Float64List(n);
  for (var i = 0; i < n; i++) {
    final a = math.max(0, i - 1), b = math.min(n - 1, i + 1);
    final dtx = x[b] - x[a], dty = y[b] - y[a];
    final l = JsMath.or(JsMath.hypot(dtx, dty), 1);
    tx[i] = dtx / l;
    ty[i] = dty / l;
    nx[i] = ty[i];
    ny[i] = -tx[i];
    th[i] = JsMath.atan2(dty, dtx);
  }
  final turn = Float64List(n);
  for (var i = 0; i < n; i++) {
    final a = math.max(0, i - 2), b = math.min(n - 1, i + 2);
    turn[i] = _wrap(th[b] - th[a]) * (4 / math.max(1, b - a));
  }
  final seg = JsMath.or(length / (n - 1), 1);
  final endMode =
      o.end ??
      switch (rng.fork('end')() < 0.5) {
        true => StrokeEnd.pool,
        false => StrokeEnd.flick,
      };
  final v = Float64List(n);
  for (var i = 0; i < n; i++) {
    final vA = math.min(1.0, JsMath.sqrt((s[i] + 0.6) / 9));
    final vD = switch (endMode) {
      StrokeEnd.flick => 1.0,
      _ => math.min(1.0, JsMath.sqrt((length - s[i] + 0.6) / 11)),
    };
    final vC = 1 / (1 + (turn[i].abs() / (4 * seg)) * 5);
    v[i] = math.min(math.min(vA, vD), vC);
  }
  for (var pass = 0; pass < 2; pass++) {
    for (var i = 1; i < n; i++) {
      v[i] = math.min(v[i], v[i - 1] * 0.55 + v[i] * 0.45 + 0.08);
    }
    for (var i = n - 2; i >= 0; i--) {
      v[i] = math.min(v[i], v[i + 1] * 0.55 + v[i] * 0.45 + 0.08);
    }
  }
  final sp = o.speed ?? 1;
  for (var i = 0; i < n; i++) {
    v[i] = clamp(v[i] * sp, 0, 1);
  }
  final startMode =
      o.start ??
      switch (rng.fork('start')() < 0.8) {
        true => StrokeStart.pool,
        false => StrokeStart.soft,
      };
  return Geo(
    x: x,
    y: y,
    s: s,
    tx: tx,
    ty: ty,
    nx: nx,
    ny: ny,
    th: th,
    turn: turn,
    v: v,
    length: length,
    n: n,
    seg: seg,
    nW9: nW9,
    nP40: nP40,
    nDry: nDry,
    nFlow: nFlow,
    nDens: nDens,
    nTooth: nTooth,
    nGap: nGap,
    endMode: endMode,
    startMode: startMode,
    capN: switch (simple) {
      true => 1,
      false => 3,
    },
  );
}
