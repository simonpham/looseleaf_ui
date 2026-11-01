import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

typedef _Lane = double Function(int i);

/// A felt or pencil stroke: halo, hairs, body, core and pools.
///
/// Mirrors `lineStroke` in `src/lib/ink/pen.ts`.
StrokeResult lineStroke(
  List<Pt> pts,
  PenSpec p,
  Rng rng,
  StrokeOpts o,
  TierCfg cfg,
  bool lo,
) {
  final g = prepare(pts, p, rng, o, cfg);
  final x = g.x,
      y = g.y,
      s = g.s,
      length = g.length,
      n = g.n,
      v = g.v,
      turn = g.turn;
  final simple = o.simple ?? false;
  final sink = Sink(switch (simple) {
    true => cfg.withTol(cfg.tol * 2.2),
    false => cfg,
  });
  final felt = p.kind == PenKind.felt;
  final w = p.w * (o.width ?? 1);
  final alpha = (o.alpha ?? 1) * p.alpha;
  final layers = <RibbonLayer>[];
  final rl = rng.fork('layers');
  final hw = Float64List(n);
  final taper = math.min(length * 0.35, (2.5 + 3.5 * w) * p.taper);
  final dryK = o.dry ?? 1;
  final cut = switch (p.gaps > 0 && !simple) {
    true => Uint8List(n),
    false => null,
  };
  for (var i = 0; i < n; i++) {
    final toEnd = length - s[i];
    final press = switch (o.press) {
      final double Function(double) fn => fn(s[i] / length),
      null => 1.0,
    };
    var h = switch (felt) {
      true => _feltHalfWidth(g, p, i, w, press, toEnd, taper, dryK),
      false => _pencilHalfWidth(g, p, i, w, press, toEnd),
    };
    if (p.dryAmt > 0 && v[i] > 0.55) {
      final d = g.nTooth(s[i]);
      if (d > 0.5) h *= 1 - 0.62 * p.dryAmt * dryK * smooth((d - 0.5) / 0.22);
    }
    if (cut != null &&
        s[i] > 4 &&
        toEnd > 4 &&
        v[i] > 0.8 &&
        g.nGap(s[i]) > 1.05 - 0.6 * p.gaps * dryK) {
      cut[i] = 1;
    }
    hw[i] = math.max(0.12, h);
  }
  if (cut != null) {
    var i = 0;
    while (i < n) {
      if (cut[i] != 1) {
        i++;
        continue;
      }
      var j = i;
      while (j < n && cut[j] == 1) {
        j++;
      }
      if (j - i < 3) {
        for (var k = i; k < j; k++) {
          cut[k] = 0;
        }
      }
      i = j + 1;
    }
  }
  String mkLane(_Lane fnL, [_Lane? fnR, List<(int, int)>? pieces]) {
    final right = fnR ?? fnL;
    final l = Float64List(n), r = Float64List(n);
    for (var i = 0; i < n; i++) {
      l[i] = fnL(i);
      r[i] = right(i);
    }
    clampInner(g, l, r);
    var d = '';
    for (final (a, b) in pieces ?? [(0, n - 1)]) {
      d += sink.poly(ribbon(g, l, r, a, b, true, true));
    }
    return d;
  }

  final color = o.color ?? p.color;
  final pieces = runs(cut, n);
  final solid = o.alpha ?? 1;
  if (!felt) {
    if (!simple) {
      layers.add(
        RibbonLayer(
          k: RibbonKind.smear,
          d: mkLane((i) => hw[i] * 1.2),
          fill: color,
          op: p.smear * solid,
        ),
      );
    }
    double pencilJitter() => switch (lo) {
      true => 0.0,
      false => rl() - 0.5,
    };
    layers.add(
      RibbonLayer(
        k: RibbonKind.body,
        d: mkLane(
          (i) => hw[i] * (1 + 0.12 * pencilJitter()),
          (i) => hw[i] * (1 + 0.12 * pencilJitter()),
          pieces,
        ),
        fill: color,
        op: alpha,
      ),
    );
    if (!simple) {
      final nc = noise1(rl, length, 40);
      double coreLane(int i) {
        if (!(hw[i] > 0.3)) return 0;
        return hw[i] *
            0.55 *
            (0.7 + 0.3 * nc(s[i] + 13)) *
            (1 + 0.4 * p.dens * g.nDens(s[i] + 5));
      }

      layers.add(
        RibbonLayer(
          k: RibbonKind.core,
          d: mkLane(coreLane),
          fill: color,
          op: alpha * 0.55,
        ),
      );
    }
    return _result(p, layers, sink, g);
  }
  final bleed = p.bleed;
  if (p.halo > 0 && !simple) {
    final nH1 = noise1(rl, length, 7), nH2 = noise1(rl, length, 7);
    var ja = 0.5, jb = 0.5;
    final ha = Float64List(n), hb = Float64List(n);
    for (var i = 0; i < n; i++) {
      ja = 0.5 * ja + 0.5 * rl();
      jb = 0.5 * jb + 0.5 * rl();
      final soak = 0.4 * (1 - v[i]);
      ha[i] =
          hw[i] +
          bleed * (0.4 + 0.85 * math.max(0, nH1(s[i])) + 0.4 * ja + soak);
      hb[i] =
          hw[i] +
          bleed * (0.4 + 0.85 * math.max(0, nH2(s[i])) + 0.4 * jb + soak);
    }
    final haloOp = switch (lo) {
      true => 0.85,
      false => 0.55,
    };
    layers.add(
      RibbonLayer(
        k: RibbonKind.halo,
        d: mkLane((i) => ha[i], (i) => hb[i]),
        fill: color,
        op: p.halo * haloOp,
      ),
    );
    if (!lo) {
      var jc = 0.5;
      final hc = Float64List(n);
      for (var i = 0; i < n; i++) {
        jc = 0.4 * jc + 0.6 * rl();
        hc[i] = hw[i] + bleed * (0.25 + 0.55 * jc);
      }
      layers.add(
        RibbonLayer(
          k: RibbonKind.halo,
          d: mkLane((i) => hc[i]),
          fill: color,
          op: p.halo,
        ),
      );
      final hairs = _hairs(g, hw, rl, sink, p, cfg);
      if (hairs.isNotEmpty) {
        layers.add(
          RibbonLayer(
            k: RibbonKind.hair,
            d: hairs,
            fill: color,
            op: math.min(1, p.halo * 1.6),
          ),
        );
      }
    }
  }
  final jit = Float64List(n);
  for (var i = 0; i < n; i++) {
    jit[i] = switch (lo) {
      true => 1.0,
      false => 1 + 0.07 * (rl() - 0.5),
    };
  }
  layers.add(
    RibbonLayer(
      k: RibbonKind.body,
      d: mkLane((i) => hw[i] * jit[i], (i) => hw[i] * jit[n - 1 - i], pieces),
      fill: color,
      op: alpha,
    ),
  );
  if (simple) return _result(p, layers, sink, g);
  final core = Float64List(n);
  var any = false;
  for (var i = 0; i < n; i++) {
    final dn = 1 + 0.6 * p.dens * g.nDens(s[i] + 17);
    final isCut = cut != null && cut[i] == 1;
    core[i] = switch (isCut) {
      true => 0.0,
      false =>
        0.72 *
            hw[i] *
            math.max(
              JsMath.pow(1 - v[i], 1.2),
              0.8 * (0.5 + 0.5 * g.nFlow(s[i])) - 0.1,
            ) *
            dn,
    };
    if (core[i] > 0.18) {
      any = true;
      continue;
    }
    core[i] = 0;
  }
  var cd = switch (any) {
    true => mkLane((i) => core[i]),
    false => '',
  };
  var pd = '';
  var hd2 = '';
  void pool(int i, double k, double jag) {
    final r = hw[i] * k * p.pool;
    pd += sink.poly(blobPts(x[i], y[i], r, jag, rl.call, 11));
    if (p.halo > 0 && !lo) {
      hd2 += sink.poly(blobPts(x[i], y[i], r + bleed * 1.5, 0.2, rl.call, 12));
    }
  }

  if (g.startMode == StrokeStart.pool) pool(0, 1.05 + 0.25 * rl(), 0.14);
  if (g.endMode == StrokeEnd.pool) pool(n - 1, 0.95 + 0.3 * rl(), 0.14);
  var lastPool = -9;
  for (var i = 2; i < n - 2; i++) {
    if (turn[i].abs() > 1.35 && i - lastPool > 4) {
      pool(i, 0.6 + 0.25 * math.min(1, turn[i].abs() - 1.35), 0.14);
      lastPool = i;
    }
  }
  if (lo) {
    cd += pd;
    pd = '';
  }
  if (cd.isNotEmpty) {
    layers.add(
      RibbonLayer(k: RibbonKind.core, d: cd, fill: color, op: p.core * solid),
    );
  }
  if (hd2.isNotEmpty) {
    layers.add(
      RibbonLayer(k: RibbonKind.halo, d: hd2, fill: color, op: p.halo * 0.9),
    );
  }
  if (pd.isNotEmpty) {
    layers.add(
      RibbonLayer(
        k: RibbonKind.pool,
        d: pd,
        fill: color,
        op: math.min(1, p.core * 1.1) * solid,
      ),
    );
  }
  return _result(p, layers, sink, g);
}

double _feltHalfWidth(
  Geo g,
  PenSpec p,
  int i,
  double w,
  double press,
  double toEnd,
  double taper,
  double dryK,
) {
  final s = g.s[i], v = g.v[i];
  var h =
      0.5 *
      w *
      (0.8 + p.swell * (1 - v)) *
      press *
      (1 + 0.1 * g.nW9(s)) *
      (1 + 0.07 * g.nP40(s));
  h *= 1 + p.dir * JsMath.sin(g.th[i]);
  h *= 1 + 0.08 * p.dens * g.nDens(s);
  h *= 1 + 0.16 * JsMath.exp(-s / 2.5);
  if (g.endMode == StrokeEnd.flick && toEnd < taper) {
    h *= 0.3 + 0.7 * JsMath.pow(math.max(0, toEnd) / taper, 0.75);
  }
  if (p.skip > 0 && v > 0.9) {
    final dry = g.nDry(s);
    final t = 1 - 0.55 * p.skip * dryK;
    if (dry > t) h *= math.max(0.42, 1 - (dry - t) * 5);
  }
  return h;
}

double _pencilHalfWidth(
  Geo g,
  PenSpec p,
  int i,
  double w,
  double press,
  double toEnd,
) {
  final s = g.s[i], length = g.length;
  final pr = 0.86 + 0.18 * g.nP40(s) + 0.1 * (1 - g.v[i]);
  final t0 = math.min(0.3 * length, 5.0);
  final t1 = math.min(
    0.4 * length,
    switch (g.endMode) {
      StrokeEnd.flick => 9.0,
      _ => 5.0,
    },
  );
  var e = 1.0;
  if (s < t0) e *= 0.5 + 0.5 * (s / t0);
  if (toEnd < t1) e *= 0.4 + 0.6 * (math.max(0, toEnd) / t1);
  final h = math.max(0.15, 0.5 * w * e * pr * press * (1 + 0.1 * g.nW9(s)));
  return h * (1 + p.dir * JsMath.sin(g.th[i]));
}

String _hairs(
  Geo g,
  Float64List hw,
  Rng rl,
  Sink sink,
  PenSpec p,
  TierCfg cfg,
) {
  final n = g.n, x = g.x, y = g.y;
  final cnt = ((g.length / 3.2) * p.feather * (0.6 + 0.8 * rl())).floor();
  final hp = PathWriter(cfg.q);
  for (var c = 0; c < cnt; c++) {
    final i = 1 + (rl() * (n - 2)).floor();
    final side = switch (rl() < 0.5) {
      true => 1,
      false => -1,
    };
    final ang = (rl() - 0.5) * 2.2;
    final nx = g.nx[i] * side, ny = g.ny[i] * side;
    final dx = nx * JsMath.cos(ang) - ny * JsMath.sin(ang),
        dy = nx * JsMath.sin(ang) + ny * JsMath.cos(ang);
    final len = hw[i] + p.bleed * (0.5 + rl() * rl() * 1.8);
    final bx = x[i] + nx * hw[i] * 0.5, by = y[i] + ny * hw[i] * 0.5;
    final bw = 0.22 + 0.3 * rl();
    final tx = g.tx[i] * bw, ty = g.ty[i] * bw;
    final Pt tip = (x[i] + dx * len, y[i] + dy * len);
    sink.grow(tip.x, tip.y);
    hp.m(bx + tx, by + ty).l(tip.x, tip.y).l(bx - tx, by - ty).z();
  }
  return hp.d;
}

StrokeResult _result(PenSpec p, List<RibbonLayer> layers, Sink sink, Geo g) =>
    StrokeResult(
      kind: p.kind,
      layers: layers,
      bbox: sink.bb,
      len: g.length,
      end: (g.x[g.n - 1], g.y[g.n - 1]),
      start: (g.x[0], g.y[0]),
    );
