import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The scene drawn on a polaroid photo.
///
/// Mirrors `POLAROID_SCENES` in `src/lib/ink/recipes/polaroid-ink.ts`.
enum PolaroidScene { hills, sea, house, night }

/// Polaroid photo recipe params.
///
/// Mirrors `PolaroidPhotoParams` in `src/lib/ink/recipes/polaroid-ink.ts`.
final class PolaroidPhotoParams {
  /// Params.
  const PolaroidPhotoParams({required this.scene});

  final PolaroidScene scene;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'scene': scene.name};
}

List<Pt> _ridge(Rng r, double w, double h, double y0, double amp, double wl) {
  final f = noise1(r, w + 40, wl);
  final top = <Pt>[];
  for (var x = -6.0; x <= w + 6; x += 8) {
    top.add((x, y0 + amp * (f(x + 6) - 0.5) * 2));
  }
  return [...spline(top, 4), (w + 8, h + 8), (-8, h + 8)];
}

List<Pt> _disc(double cx, double cy, double r) =>
    ellipsePoly(cx, cy, r, r * 0.97, 22);

void _pen(
  Ink ink,
  List<Pt> pts,
  PenName name, {
  double? alpha,
  double? width,
  bool? poly,
}) => ink.stroke(
  pts,
  name,
  StrokeOpts(simple: true, alpha: alpha, width: width, poly: poly),
);

void _ring(Ink ink, double cx, double cy, double rx, double ry, PenName name) {
  final r = ink.next('ring');
  final a0 = r.range(0, tau);
  final pts = <Pt>[];
  for (var i = 0; i <= 26; i++) {
    final t = a0 + (i / 26) * tau * 1.06;
    final k = 1 + 0.018 * JsMath.sin(t * 2 + a0) + (i / 26) * 0.03;
    pts.add((cx + JsMath.cos(t) * rx * k, cy + JsMath.sin(t) * ry * k));
  }
  _pen(ink, spline(pts, 3), name);
}

void _puff(Ink ink, double cx, double cy, double w, double h) {
  final r = ink.next('puff');
  final bumps = switch (w > h * 3) {
    true => 4,
    false => 3,
  };
  final sw = w / bumps;
  final base = cy + h / 2;
  final pts = <Pt>[(cx - w / 2 - 3, base + 0.6)];
  for (var i = 0; i < bumps; i++) {
    final mid = i > 0 && i < bumps - 1;
    final lift =
        h *
        switch (mid) {
          true => r.range(1.05, 1.35),
          false => r.range(0.6, 0.8),
        };
    final xc = cx - w / 2 + sw * (i + 0.5);
    for (var k = 0; k <= 8; k++) {
      final a = JsMath.pi + (k / 8) * JsMath.pi;
      pts.add((
        xc + JsMath.cos(a) * sw * 0.55,
        base - JsMath.sin(-a) * lift + 0,
      ));
    }
  }
  pts.add((cx + w / 2 + 3, base + 0.4));
  _pen(ink, spline(pts, 2.5), PenName.pencil);
}

void _twinkle(Ink ink, double cx, double cy, double r) => blobFill(
  ink,
  [
    (cx, cy - r),
    (cx + r * 0.28, cy - r * 0.28),
    (cx + r, cy),
    (cx + r * 0.28, cy + r * 0.28),
    (cx, cy + r),
    (cx - r * 0.28, cy + r * 0.28),
    (cx - r, cy),
    (cx - r * 0.28, cy - r * 0.28),
  ],
  PaintKey.lemon,
  alpha: 0.95,
  mis: 0.6,
  rough: 0.3,
);

void _sun(Ink ink, double cx, double cy, double r, [int rays = 9]) {
  blobFill(ink, _disc(cx, cy, r), PaintKey.lemon, alpha: 0.95);
  _ring(ink, cx, cy, r * 1.02, r, PenName.fTangerine);
  final g = ink.next('rays');
  for (var i = 0; i < rays; i++) {
    final a = (i / rays) * JsMath.pi * 2 + g.range(-0.12, 0.12);
    final r0 = r * 1.5, r1 = r * g.range(1.85, 2.25);
    _pen(ink, [
      (cx + JsMath.cos(a) * r0, cy + JsMath.sin(a) * r0),
      (cx + JsMath.cos(a) * r1, cy + JsMath.sin(a) * r1),
    ], PenName.fTangerine);
  }
}

void _tree(
  Ink ink,
  double x,
  double y,
  double s, [
  PaintKey crown = PaintKey.grass,
]) {
  blobFill(
    ink,
    rectPoly(x - s * 0.035, y - s * 0.56, s * 0.08, s * 0.56),
    PaintKey.orangeText,
    alpha: 0.85,
    mis: 1,
  );
  ink.stroke(
    [(x - s * 0.035, y), (x - s * 0.04, y - s * 0.52)],
    PenName.ink,
    const StrokeOpts(width: 1.1),
  );
  final cy = y - s * 0.86;
  blobFill(
    ink,
    ellipsePoly(x, cy, s * 0.42, s * 0.4, 22, 0.2),
    crown,
    alpha: 0.92,
  );
  _ring(ink, x - s * 0.02, cy, s * 0.43, s * 0.4, PenName.greenfelt);
  final g = ink.next('fruit');
  for (var i = 0; i < 3; i++) {
    ink.dot(
      x + g.range(-s * 0.22, s * 0.22),
      cy + g.range(-s * 0.2, s * 0.2),
      s * 0.045,
      PenName.fTomato,
    );
  }
}

void _drawHills(Ink ink, double w, double h) {
  final r = ink.next('scene');
  wash(ink, rectPoly(0, 0, w, h * 0.62), PaintKey.sky, alpha: 0.46, inset: -4);
  _sun(ink, w * 0.72, h * 0.25, w * 0.085);
  _puff(ink, w * 0.27, h * 0.2, w * 0.28, h * 0.1);
  _puff(ink, w * 0.5, h * 0.37, w * 0.15, h * 0.055);
  blobFill(
    ink,
    _ridge(r.fork('far'), w, h, h * 0.55, h * 0.045, 60),
    PaintKey.teal,
    alpha: 0.55,
  );
  blobFill(
    ink,
    _ridge(r.fork('mid'), w, h, h * 0.66, h * 0.05, 70),
    PaintKey.grass,
    alpha: 0.72,
  );
  bandFill(
    ink,
    _ridge(r.fork('near'), w, h, h * 0.83, h * 0.035, 50),
    PaintKey.grass,
    alpha: 0.9,
    angle: 0.15,
  );
  hatch(
    ink,
    rectRegion(w * 0.06, h * 0.9, w * 0.88, h * 0.08),
    angle: 62,
    gap: 9,
    pen: PenName.pencil,
    alpha: 0.35,
  );
  _tree(ink, w * 0.25, h * 0.8, h * 0.34);
  final g = r.fork('flowers');
  for (var i = 0; i < 5; i++) {
    ink.dot(
      w * g.range(0.45, 0.92),
      h * g.range(0.86, 0.96),
      h * 0.014,
      switch (i % 2) {
        0 => PenName.fLemon,
        _ => PenName.fBubblegum,
      },
    );
  }
}

void _drawSea(Ink ink, double w, double h) {
  final r = ink.next('scene');
  wash(
    ink,
    rectPoly(0, 0, w, h * 0.55),
    PaintKey.tangerine,
    alpha: 0.24,
    inset: -4,
  );
  blobFill(
    ink,
    _disc(w * 0.66, h * 0.5, w * 0.11),
    PaintKey.lemon,
    alpha: 0.96,
  );
  _ring(ink, w * 0.66, h * 0.5, w * 0.115, w * 0.11, PenName.fTangerine);
  bandFill(
    ink,
    rectPoly(-4, h * 0.52, w + 8, h * 0.5),
    PaintKey.sky,
    alpha: 0.8,
    angle: 0.03,
  );
  wash(
    ink,
    rectPoly(-4, h * 0.72, w + 8, h * 0.3),
    PaintKey.teal,
    alpha: 0.6,
    inset: -2,
  );
  _pen(ink, [
    (-2, h * 0.52),
    (w * 0.5, h * 0.522),
    (w + 2, h * 0.516),
  ], PenName.inkFine);
  final g = r.fork('waves');
  for (var i = 0; i < 9; i++) {
    final y = h * (0.6 + 0.36 * (i / 9)) + g.range(-3, 3);
    final x = w * g.range(0.02, 0.7);
    final len = w * g.range(0.14, 0.26);
    _pen(
      ink,
      spline([
        (x, y),
        (x + len * 0.25, y - 3.4),
        (x + len * 0.5, y),
        (x + len * 0.75, y - 3.4),
        (x + len, y),
      ], 3),
      PenName.pencilFine,
      alpha: 0.8,
    );
  }
  final bx = w * 0.3, by = h * 0.68, s = w * 0.2;
  final hull = <Pt>[
    (bx - s * 0.5, by),
    (bx + s * 0.55, by),
    (bx + s * 0.38, by + s * 0.22),
    (bx - s * 0.32, by + s * 0.22),
  ];
  blobFill(ink, hull, PaintKey.tomato, alpha: 0.95, mis: 1);
  _pen(ink, [...hull, hull[0]], PenName.ink, poly: true, width: 0.8);
  _pen(ink, [(bx + s * 0.02, by), (bx + s * 0.02, by - s * 1.05)], PenName.ink);
  final front = <Pt>[
    (bx + s * 0.08, by - s * 1.0),
    (bx + s * 0.08, by - s * 0.08),
    (bx + s * 0.48, by - s * 0.1),
  ];
  blobFill(ink, front, PaintKey.paper, alpha: 0.98, mis: 1);
  ink.stroke(
    [...front, front[0]],
    PenName.ink,
    const StrokeOpts(poly: true, width: 0.8),
  );
  final back = <Pt>[
    (bx - s * 0.04, by - s * 0.9),
    (bx - s * 0.04, by - s * 0.1),
    (bx - s * 0.36, by - s * 0.12),
  ];
  blobFill(ink, back, PaintKey.photo, alpha: 0.98, mis: 1);
  _pen(ink, [...back, back[0]], PenName.ink, poly: true, width: 0.8);
  for (final (gx, gy) in const [(0.2, 0.18), (0.34, 0.26), (0.13, 0.3)]) {
    _pen(
      ink,
      spline([
        (w * gx - 7, h * gy),
        (w * gx - 3, h * gy - 4),
        (w * gx, h * gy),
        (w * gx + 3, h * gy - 4),
        (w * gx + 7, h * gy),
      ], 3),
      PenName.inkFine,
    );
  }
}

void _drawHouse(Ink ink, double w, double h) {
  final r = ink.next('scene');
  wash(ink, rectPoly(0, 0, w, h * 0.7), PaintKey.sky, alpha: 0.4, inset: -4);
  _sun(ink, w * 0.16, h * 0.17, w * 0.075, 8);
  blobFill(
    ink,
    _ridge(r.fork('lawn'), w, h, h * 0.7, h * 0.02, 80),
    PaintKey.grass,
    alpha: 0.85,
  );
  hatch(
    ink,
    rectRegion(w * 0.04, h * 0.76, w * 0.92, h * 0.2),
    angle: 64,
    gap: 9,
    pen: PenName.greenfelt,
    alpha: 0.35,
    width: 0.7,
  );
  final x = w * 0.36, y = h * 0.46, ww = w * 0.36, hh = h * 0.27;
  blobFill(ink, rectPoly(x, y, ww, hh), PaintKey.lemon, alpha: 0.92, mis: 2.4);
  ink.stroke(
    [(x, y + hh), (x, y), (x + ww, y), (x + ww, y + hh)],
    PenName.ink,
    const StrokeOpts(poly: true),
  );
  _pen(ink, [(x - 4, y + hh), (x + ww + 4, y + hh)], PenName.ink);
  final roof = <Pt>[
    (x - ww * 0.1, y + 1),
    (x + ww / 2, y - hh * 0.62),
    (x + ww * 1.1, y + 1),
  ];
  blobFill(ink, roof, PaintKey.tomato, alpha: 0.95, mis: 2);
  ink.stroke([...roof, roof[0]], PenName.ink, const StrokeOpts(poly: true));
  _pen(
    ink,
    [
      (x + ww * 0.78, y - hh * 0.32),
      (x + ww * 0.78, y - hh * 0.72),
      (x + ww * 0.94, y - hh * 0.72),
      (x + ww * 0.94, y - hh * 0.14),
    ],
    PenName.ink,
    poly: true,
    width: 0.85,
  );
  blobFill(
    ink,
    rectPoly(x + ww * 0.14, y + hh * 0.36, ww * 0.24, hh * 0.64),
    PaintKey.grape,
    alpha: 0.9,
    mis: 1,
  );
  _pen(
    ink,
    [
      (x + ww * 0.14, y + hh),
      (x + ww * 0.14, y + hh * 0.36),
      (x + ww * 0.38, y + hh * 0.36),
      (x + ww * 0.38, y + hh),
    ],
    PenName.ink,
    poly: true,
    width: 0.9,
  );
  blobFill(
    ink,
    rectPoly(x + ww * 0.56, y + hh * 0.26, ww * 0.26, ww * 0.24),
    PaintKey.sky,
    alpha: 0.95,
    mis: 1,
  );
  _pen(
    ink,
    [
      (x + ww * 0.56, y + hh * 0.26),
      (x + ww * 0.82, y + hh * 0.26),
      (x + ww * 0.82, y + hh * 0.26 + ww * 0.24),
      (x + ww * 0.56, y + hh * 0.26 + ww * 0.24),
      (x + ww * 0.56, y + hh * 0.26),
    ],
    PenName.ink,
    poly: true,
    width: 0.9,
  );
  _pen(ink, [
    (x + ww * 0.69, y + hh * 0.26),
    (x + ww * 0.69, y + hh * 0.26 + ww * 0.24),
  ], PenName.inkFine);
  final smoke = <Pt>[
    (x + ww * 0.86, y - hh * 0.78),
    (x + ww * 0.92, y - hh * 0.98),
    (x + ww * 0.82, y - hh * 1.16),
    (x + ww * 0.92, y - hh * 1.32),
  ];
  _pen(ink, spline(smoke, 3), PenName.pencil, alpha: 0.8);
  _tree(ink, w * 0.13, h * 0.8, h * 0.36, PaintKey.tomato);
  _pen(
    ink,
    spline([
      (x + ww * 0.26, y + hh),
      (x + ww * 0.1, h * 0.86),
      (w * 0.3, h * 0.97),
    ], 3),
    PenName.pencil,
    alpha: 0.7,
  );
}

/// A crescent: the circle at ([cx], [cy]) with radius [bigR] minus the
/// circle offset by ([bx], [by]) with radius [r2], as one outline.
///
/// Mirrors `crescent` in `src/lib/ink/recipes/polaroid-ink.ts`.
List<Pt> crescent(
  double cx,
  double cy,
  double bigR,
  double bx,
  double by,
  double r2, [
  int n = 14,
]) {
  final d = JsMath.hypot(bx, by);
  final ux = bx / d;
  final uy = by / d;
  final a = (bigR * bigR - r2 * r2 + d * d) / (2 * d);
  final hh = JsMath.sqrt(math.max(0, bigR * bigR - a * a));
  final mx = cx + a * ux;
  final my = cy + a * uy;
  final ends = <Pt>[(mx - hh * uy, my + hh * ux), (mx + hh * uy, my - hh * ux)];
  final away = JsMath.atan2(-uy, -ux);
  double wrap(double t) => JsMath.atan2(JsMath.sin(t), JsMath.cos(t));
  double rel(Pt p, double ox, double oy) =>
      wrap(JsMath.atan2(p.y - oy, p.x - ox) - away);
  final (lo, hi) = switch (rel(ends[0], cx, cy) < rel(ends[1], cx, cy)) {
    true => (ends[0], ends[1]),
    false => (ends[1], ends[0]),
  };
  final pts = <Pt>[];
  final t0 = rel(lo, cx, cy);
  final t1 = rel(hi, cx, cy);
  for (var i = 0; i <= n; i++) {
    final t = away + t0 + ((t1 - t0) * i) / n;
    pts.add((cx + JsMath.cos(t) * bigR, cy + JsMath.sin(t) * bigR * 0.97));
  }
  final e0 = rel(hi, cx + bx, cy + by);
  final e1 = rel(lo, cx + bx, cy + by);
  for (var i = 0; i <= n; i++) {
    final t = away + e0 + ((e1 - e0) * i) / n;
    pts.add((
      cx + bx + JsMath.cos(t) * r2,
      cy + by + JsMath.sin(t) * r2 * 0.97,
    ));
  }
  return pts;
}

void _drawNight(Ink ink, double w, double h) {
  final r = ink.next('scene');
  wash(ink, rectPoly(0, 0, w, h), PaintKey.grape, alpha: 0.5, inset: -4);
  wash(ink, rectPoly(0, 0, w, h), PaintKey.ink, alpha: 0.42, inset: -4);
  blobFill(
    ink,
    crescent(w * 0.68, h * 0.26, w * 0.1, w * 0.05, -w * 0.03, w * 0.088),
    PaintKey.lemon,
    alpha: 0.98,
    mis: 1,
  );
  final g = r.fork('stars');
  for (var i = 0; i < 9; i++) {
    final sx = w * g.range(0.06, 0.94);
    final sy = h * g.range(0.05, 0.5);
    final sr = w * g.range(0.014, 0.034);
    if (JsMath.hypot(sx - w * 0.7, sy - h * 0.25) > w * 0.17) {
      _twinkle(ink, sx, sy, sr);
    }
  }
  final roofs = <Pt>[(-6, h + 6), (-6, h * 0.8)];
  var x = -6.0;
  while (x < w + 6) {
    final bw = w * g.range(0.2, 0.3);
    final top = h * g.range(0.64, 0.79);
    roofs.addAll([(x, top), (x + bw / 2, top - bw * 0.35), (x + bw, top)]);
    x += bw;
  }
  roofs.addAll([(w + 6, h * 0.8), (w + 6, h + 6)]);
  blobFill(ink, roofs, PaintKey.ink, alpha: 0.9, mis: 1);
  for (var i = 0; i < 7; i++) {
    final wx = w * g.range(0.05, 0.92);
    final wy =
        h *
        switch (wx > w * 0.62) {
          true => g.range(0.81, 0.845),
          false => g.range(0.81, 0.9),
        };
    blobFill(
      ink,
      rectPoly(wx, wy, w * 0.035, w * 0.045),
      PaintKey.lemon,
      alpha: 0.95,
      mis: 0,
      material: Material.top,
    );
  }
}

/// A hand-drawn snapshot (hills, sea, house or night) for a polaroid.
///
/// Mirrors `polaroidPhotoRecipe` in `src/lib/ink/recipes/polaroid-ink.ts`.
final Recipe<PolaroidPhotoParams> polaroidPhotoRecipe =
    defineRecipe<PolaroidPhotoParams>(
      id: 'polaroid-photo',
      kind: 'photo',
      layers: const [LayerName.rest],
      pad: 4,
      draw: _draw,
    );

void _draw(Ink ink, Box size, PolaroidPhotoParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ink.layer(LayerName.rest, () {
    switch (params.scene) {
      case PolaroidScene.sea:
        _drawSea(ink, w, h);
      case PolaroidScene.house:
        _drawHouse(ink, w, h);
      case PolaroidScene.night:
        _drawNight(ink, w, h);
      case PolaroidScene.hills:
        _drawHills(ink, w, h);
    }
  });
}
