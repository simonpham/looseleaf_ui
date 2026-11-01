import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// Collects outline bounds while turning polygons into smooth paths.
///
/// Mirrors `Sink` in `src/lib/ink/pen.ts`.
final class Sink {
  /// A sink writing on [cfg]'s grid.
  Sink(this.cfg);

  /// The bounds so far.
  final BBox bb = BBox.empty();

  /// The tier settings.
  final TierCfg cfg;

  /// Grows the bounds.
  void grow(double x, double y) => bb.grow(x, y);

  /// The smooth closed path of [pts], growing the bounds.
  String poly(List<Pt> pts) {
    for (final p in pts) {
      grow(p.x, p.y);
    }
    return smoothClosed(pts, cfg);
  }
}

/// A jagged ring of [nv] points: a blot of ink.
///
/// Mirrors `blobPts` in `src/lib/ink/pen.ts`.
List<Pt> blobPts(
  double cx,
  double cy,
  double r,
  double jag,
  double Function() rnd, [
  int nv = 10,
  double sx = 1,
  double sy = 1,
  double rot = 0,
]) {
  final pts = <Pt>[];
  final a0 = rnd() * tau;
  for (var i = 0; i < nv; i++) {
    final a = a0 + (i / nv) * tau;
    final rr = r * (1 + jag * (rnd() * 2 - 1));
    final x = JsMath.cos(a) * rr * sx, y = JsMath.sin(a) * rr * sy;
    pts.add((
      cx + x * JsMath.cos(rot) - y * JsMath.sin(rot),
      cy + x * JsMath.sin(rot) + y * JsMath.cos(rot),
    ));
  }
  return pts;
}
