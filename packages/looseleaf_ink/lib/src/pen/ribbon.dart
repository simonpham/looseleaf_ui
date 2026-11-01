import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The outline of the spine from [a] to [b], [lo] to the left and [ro] to
/// the right, with round caps.
///
/// Mirrors `ribbon` in `src/lib/ink/pen.ts`.
List<Pt> ribbon(
  Geo g,
  Float64List lo,
  Float64List ro,
  int a,
  int b, [
  bool capS = true,
  bool capE = true,
]) {
  final x = g.x,
      y = g.y,
      nx = g.nx,
      ny = g.ny,
      tx = g.tx,
      ty = g.ty,
      capN = g.capN;
  final pts = <Pt>[];
  for (var i = a; i <= b; i++) {
    pts.add((x[i] + nx[i] * lo[i], y[i] + ny[i] * lo[i]));
  }
  if (capE) {
    final r = (lo[b] + ro[b]) / 2;
    for (var k = 1; k <= capN; k++) {
      final ph = (k / (capN + 1)) * JsMath.pi;
      final c = JsMath.cos(ph), s = JsMath.sin(ph);
      final w = switch (c >= 0) {
        true => lo[b],
        false => ro[b],
      };
      pts.add((
        x[b] + nx[b] * w * c + tx[b] * r * s,
        y[b] + ny[b] * w * c + ty[b] * r * s,
      ));
    }
  }
  for (var i = b; i >= a; i--) {
    pts.add((x[i] - nx[i] * ro[i], y[i] - ny[i] * ro[i]));
  }
  if (capS) {
    final r = (lo[a] + ro[a]) / 2;
    for (var k = 1; k <= capN; k++) {
      final ph = (k / (capN + 1)) * JsMath.pi;
      final c = JsMath.cos(ph), s = JsMath.sin(ph);
      final w = switch (c >= 0) {
        true => ro[a],
        false => lo[a],
      };
      pts.add((
        x[a] - nx[a] * w * c - tx[a] * r * s,
        y[a] - ny[a] * w * c - ty[a] * r * s,
      ));
    }
  }
  return pts;
}

/// Limits the inner side of tight turns so the outline does not fold.
///
/// Mirrors `clampInner` in `src/lib/ink/pen.ts`.
void clampInner(Geo g, Float64List lo, Float64List ro) {
  for (var i = 0; i < g.n; i++) {
    final k = g.turn[i].abs() / (4 * g.seg);
    if (k < 1e-3) continue;
    final lim = 0.85 / k;
    if (g.turn[i] > 0) {
      ro[i] = math.min(ro[i], lim);
      continue;
    }
    lo[i] = math.min(lo[i], lim);
  }
}

/// The uncut index runs `(a, b)` of a stroke with [cut] marks.
///
/// Mirrors `runs` in `src/lib/ink/pen.ts`.
List<(int, int)> runs(Uint8List? cut, int n) {
  if (cut == null) return [(0, n - 1)];
  final out = <(int, int)>[];
  var a = -1;
  for (var i = 0; i <= n; i++) {
    final c = i == n || cut[i] == 1;
    if (!c && a < 0) a = i;
    if (c && a >= 0) {
      if (i - 1 - a >= 1) out.add((a, i - 1));
      a = -1;
    }
  }
  return out;
}
