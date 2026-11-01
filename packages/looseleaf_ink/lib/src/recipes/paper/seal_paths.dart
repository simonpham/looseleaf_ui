import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// [v] rounded to 0.1, as a JS number string.
///
/// Mirrors `r1` in `src/lib/ink/recipes/seal-ink.ts`.
String sealR1(double v) => JsMath.numberToString(sealRound(v));

/// [v] rounded to 0.1.
double sealRound(double v) => JsMath.round(v * 10) / 10;

/// A scalloped ring of [bumps] arcs between radius [r0] and [peak].
///
/// Mirrors `scalloped` in `src/lib/ink/recipes/seal-ink.ts`.
String scalloped(
  double cx,
  double cy,
  double r0,
  double peak,
  int bumps, [
  double rot = 0,
]) {
  final d = StringBuffer();
  Pt pt(double a, double r) => (cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r);
  for (var i = 0; i < bumps; i++) {
    final a0 = rot + (i / bumps) * tau, a1 = rot + ((i + 1) / bumps) * tau;
    final v = pt(a0, r0 + (i % 3) * 0.12),
        c = pt((a0 + a1) / 2, peak + ((i * 7) % 5) * 0.08),
        e = pt(a1, r0 + (((i + 1) % bumps) % 3) * 0.12);
    if (i == 0) d.write('M${sealR1(v.x)} ${sealR1(v.y)}');
    d.write(' Q${sealR1(c.x)} ${sealR1(c.y)} ${sealR1(e.x)} ${sealR1(e.y)}');
  }
  return '$d Z';
}

/// A check mark of size [s] centred on `(cx, cy)`.
///
/// Mirrors `checkPath` in `src/lib/ink/recipes/seal-ink.ts`.
String sealCheckPath(double cx, double cy, double s) =>
    'M${sealR1(cx - 0.42 * s)} ${sealR1(cy + 0.04 * s)} '
    'L${sealR1(cx - 0.1 * s)} ${sealR1(cy + 0.36 * s)} '
    'L${sealR1(cx + 0.5 * s)} ${sealR1(cy - 0.38 * s)}';

/// A five-pointed star of outer radius [ro].
///
/// Mirrors `starPath` in `src/lib/ink/recipes/seal-ink.ts`.
String sealStarPath(double cx, double cy, double ro) {
  final d = StringBuffer();
  for (var i = 0; i < 10; i++) {
    final a = ((-90 + i * 36) * JsMath.pi) / 180;
    final r = switch (i.isOdd) {
      true => ro * 0.44,
      false => ro,
    };
    final lead = switch (i) {
      0 => 'M',
      _ => ' L',
    };
    d.write(
      '$lead${sealR1(cx + JsMath.cos(a) * r)} ${sealR1(cy + JsMath.sin(a) * r)}',
    );
  }
  return '$d Z';
}
