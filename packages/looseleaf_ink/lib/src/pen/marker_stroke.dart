import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

typedef _Lane = double Function(int i);

/// A chisel marker or highlighter stroke: wet halo, body, rims, streaks
/// and dry slits.
///
/// Mirrors `markerStroke` in `src/lib/ink/pen.ts`.
StrokeResult markerStroke(
  List<Pt> pts,
  PenSpec p,
  Rng rng,
  StrokeOpts o,
  TierCfg cfg,
  bool lo,
) {
  final g = prepare(
    pts,
    p,
    rng,
    o.copyWith(start: o.start ?? StrokeStart.pool),
    cfg,
  );
  final x = g.x, y = g.y, s = g.s, length = g.length, n = g.n;
  final sink = Sink(cfg);
  final w = p.w * (o.width ?? 1);
  final alpha = (o.alpha ?? 1) * p.alpha;
  final rl = rng.fork('layers');
  final hl = p.kind == PenKind.hl;
  final color = o.color ?? p.color;
  final hwA = Float64List(n);
  final nM = noise1(rl, length, 14),
      nE = noise1(rl, length, 3.5),
      nE2 = noise1(rl, length, 3.5);
  final taper = math.min(0.25 * length, 0.5 * w);
  final cutLen = math.min(w * p.cutK, length * 0.4);
  final slantA = switch (rl() < 0.5) {
    true => 1,
    false => -1,
  };
  final left = Float64List(n), right = Float64List(n);
  for (var i = 0; i < n; i++) {
    final ang = JsMath.atan2(g.ty[i], g.tx[i]);
    final chisel = switch (hl) {
      true => 0.8 + 0.2 * JsMath.sin(ang - p.nib).abs(),
      false => 0.5 + 0.5 * JsMath.sin(ang - p.nib).abs(),
    };
    final press = switch (o.press) {
      final double Function(double) fn => fn(s[i] / length),
      null => 1.0,
    };
    var hw = 0.5 * w * chisel * press * (1 + 0.06 * nM(s[i]));
    if (g.endMode == StrokeEnd.flick && length - s[i] < taper) {
      hw *= 0.6 + 0.4 * ((length - s[i]) / taper);
    }
    hwA[i] = hw;
    var a = hw * (1 + 0.35 * p.edge * nE(s[i]) * 0.5);
    var b = hw * (1 + 0.35 * p.edge * nE2(s[i]) * 0.5);
    if (s[i] < cutLen) {
      final c = 1 - 0.6 * (1 - s[i] / cutLen);
      if (slantA > 0) a *= c;
      if (slantA <= 0) b *= c;
    }
    if (length - s[i] < cutLen) {
      final c = 1 - 0.6 * (1 - (length - s[i]) / cutLen);
      if (slantA > 0) b *= c;
      if (slantA <= 0) a *= c;
    }
    left[i] = a;
    right[i] = b;
  }
  final layers = <RibbonLayer>[];
  String lane(_Lane l2, _Lane r2) {
    final a = Float64List(n), b = Float64List(n);
    for (var i = 0; i < n; i++) {
      a[i] = l2(i);
      b[i] = r2(i);
    }
    clampInner(g, a, b);
    return sink.poly(ribbon(g, a, b, 0, n - 1, false, false));
  }

  layers.add(
    RibbonLayer(
      k: RibbonKind.halo,
      d: lane(
        (i) => left[i] + p.bleed * (0.5 + 0.5 * nE(s[i] + 9)),
        (i) => right[i] + p.bleed * (0.5 + 0.5 * nE2(s[i] + 9)),
      ),
      fill: color,
      op: alpha * p.wet,
    ),
  );
  var body = lane((i) => left[i], (i) => right[i]);
  final rw1 = switch (hl) {
    true => 0.55,
    false => 0.8,
  };
  final rimLeft = lane(
    (i) => left[i],
    (i) => -left[i] + rw1 * (0.6 + 0.8 * rl()),
  );
  final rim =
      rimLeft +
      lane((i) => -right[i] + rw1 * (0.6 + 0.8 * rl()), (i) => right[i]);
  var evenOdd = false;
  final extra = <RibbonLayer>[];
  if (!hl && !lo && length > 6) {
    final nS = noise1(rl, length, 30);
    for (var k = 0; k < 2; k++) {
      final base = (rl() - 0.5) * 0.9;
      double off(int i) => hwA[i] * (base + 0.25 * nS(s[i] + k * 40));
      extra.add(
        RibbonLayer(
          k: RibbonKind.streak,
          d: lane(
            (i) => math.max(0.1, 0.3 + off(i)),
            (i) => math.max(0.1, 0.3 - off(i)),
          ),
          fill: color,
          op: p.edge * 0.5,
        ),
      );
    }
    final slits = _slits(g, hwA, rl, cfg, noise1(rl, length, 11));
    if (slits.isNotEmpty) {
      body += slits;
      evenOdd = true;
    }
  }
  layers
    ..add(
      RibbonLayer(
        k: RibbonKind.body,
        d: body,
        fill: color,
        op: alpha,
        evenOdd: evenOdd,
      ),
    )
    ..add(RibbonLayer(k: RibbonKind.rim, d: rim, fill: color, op: p.edge))
    ..addAll(extra);
  return StrokeResult(
    kind: p.kind,
    layers: layers,
    bbox: sink.bb,
    len: length,
    end: (x[n - 1], y[n - 1]),
    start: (x[0], y[0]),
  );
}

String _slits(
  Geo g,
  Float64List hwA,
  Rng rl,
  TierCfg cfg,
  double Function(double) nGap,
) {
  final n = g.n, x = g.x, y = g.y, s = g.s;
  var sd = '';
  var inSlit = false;
  var sIdx = 0;
  for (var i = 0; i < n; i++) {
    final threshold = switch (g.v[i] > 0.8) {
      true => 0.3,
      false => 0.5,
    };
    final dry = math.max(0, nGap(s[i] + 31) - threshold);
    if (dry > 0.3 && !inSlit) {
      inSlit = true;
      sIdx = i;
    }
    if (!((dry <= 0.3 || i == n - 1) && inSlit)) continue;
    inSlit = false;
    if (i - sIdx <= 4) continue;
    final off = hwA[sIdx] * (rl() - 0.5) * 0.7;
    final top = <Pt>[], bot = <Pt>[];
    for (var j = sIdx; j < i; j++) {
      final tt = (j - sIdx) / (i - sIdx);
      final wdt = 0.28 * JsMath.sin(JsMath.pi * tt);
      top.add((x[j] + g.nx[j] * (off + wdt), y[j] + g.ny[j] * (off + wdt)));
      bot.insert(0, (
        x[j] + g.nx[j] * (off - wdt),
        y[j] + g.ny[j] * (off - wdt),
      ));
    }
    sd += smoothClosed([...top, ...bot], cfg);
  }
  return sd;
}
