import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/edges.dart';

/// One sample along a side: position [u], edge depth [e], fibre reach [f].
final class EdgeSample {
  /// A sample.
  const EdgeSample(this.u, this.e, this.f);

  /// Distance along the side.
  final double u;

  /// Depth of the edge into the sheet.
  final double e;

  /// How far fibres stick out past the edge.
  final double f;
}

final class _Rough {
  const _Rough(this.b, this.lo, this.mid, this.hi, this.f0, this.f1, this.step);

  final double b, lo, mid, hi, f0, f1, step;
}

_Rough _roughOf(EdgeKind kind) => switch (kind) {
  EdgeKind.crimp => const _Rough(1.5, 0.6, 0.36, 0.15, 0.3, 0.3, 2.1),
  EdgeKind.torn => const _Rough(2.5, 1.5, 1.15, 0.6, 0.9, 0.8, 1.7),
  EdgeKind.deckle => const _Rough(2.3, 1.3, 0.95, 0.42, 1.5, 1, 1.9),
  _ => const _Rough(0.55, 0.16, 0, 0.05, 0, 0, 14),
};

List<EdgeSample> _roughSide(EdgeKind kind, double len, Rng rng, double amp) {
  final k = _roughOf(kind);
  final lo = noise1(rng.fork('lo'), len, 22);
  final mid = noise1(rng.fork('mid'), len, 3.2);
  final hi = noise1(rng.fork('hi'), len, 0.9);
  final fz = noise1(rng.fork('fz'), len, 1.1);
  final cnt = math.max(2, JsMath.roundInt(len / k.step));
  return [
    for (var i = 0; i <= cnt; i++)
      _roughSample(k, (i / cnt) * len, len, amp, lo, mid, hi, fz),
  ];
}

EdgeSample _roughSample(
  _Rough k,
  double u,
  double len,
  double amp,
  double Function(double) lo,
  double Function(double) mid,
  double Function(double) hi,
  double Function(double) fz,
) {
  final fade = math.min(math.min(1.0, u / 7), (len - u) / 7);
  final e =
      math.max(
        0.15,
        (k.b + k.lo * lo(u) + k.mid * mid(u) + k.hi * hi(u)) * amp,
      ) *
      (0.35 + 0.65 * fade);
  final f = math.max(0.0, k.f0 + k.f1 * fz(u)) * amp * fade;
  return EdgeSample(u, e, f);
}

List<EdgeSample> _zigSide(double len, Rng rng, double amp) {
  final n = math.max(2, JsMath.roundInt(len / zigEdge.pitch));
  final pitch = len / n;
  final jit = noise1(rng.fork('zj'), len, 30);
  final out = <EdgeSample>[];
  for (var i = 0; i <= n; i++) {
    out.add(EdgeSample(i * pitch, 0.15, 0));
    if (i < n) {
      out.add(
        EdgeSample(
          (i + 0.5) * pitch,
          (zigEdge.depth + 0.5 * jit((i + 0.5) * pitch)) * amp,
          0,
        ),
      );
    }
  }
  return out;
}

List<EdgeSample> _perfSide(double len, Rng rng, double amp) {
  final n = math.max(2, JsMath.roundInt(len / perfEdge.pitch));
  final pitch = len / n;
  final jit = noise1(rng.fork('pj'), len, 40);
  final out = <EdgeSample>[const EdgeSample(0, 0.3, 0)];
  for (var i = 0; i < n; i++) {
    final c = (i + 0.5) * pitch;
    final r = pitch * 0.4;
    final depth = (perfEdge.depth + 0.3 * jit(c)) * amp;
    for (var k = 0; k <= 6; k++) {
      final a = JsMath.pi * (k / 6);
      out.add(
        EdgeSample(c - JsMath.cos(a) * r, 0.3 + JsMath.sin(a) * depth, 0),
      );
    }
  }
  out.add(EdgeSample(len, 0.3, 0));
  return out;
}

List<EdgeSample> _scallopSide(double len, Rng rng, double amp) {
  final n = math.max(2, JsMath.roundInt(len / scallopPitch));
  final pitch = len / n;
  final radius = pitch / 2;
  final out = <EdgeSample>[];
  for (var i = 0; i < n; i++) {
    final c = (i + 0.5) * pitch;
    final wob = 1 + 0.05 * (rng.fork('s$i')() - 0.5);
    for (var k = 0; k <= 12; k++) {
      final a = -JsMath.pi / 2 + JsMath.pi * (k / 12);
      out.add(
        EdgeSample(
          c + JsMath.sin(a) * radius * 0.98,
          0.15 + radius * 0.6 * (1 - JsMath.cos(a)) * amp * wob,
          0,
        ),
      );
    }
  }
  return out;
}

/// The samples of one side of [kind], [len] long.
///
/// Mirrors `side` in `src/lib/ink/paper/edges.ts`.
List<EdgeSample> edgeSamples(EdgeKind kind, double len, Rng rng, double amp) =>
    switch (kind) {
      EdgeKind.zig => _zigSide(len, rng, amp),
      EdgeKind.perf => _perfSide(len, rng, amp),
      EdgeKind.scallop => _scallopSide(len, rng, amp),
      _ => _roughSide(kind, len, rng, amp),
    };
