import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The rating icon.
enum RatingIcon {
  star(PaintKey.hi),
  heart(PaintKey.tomato),
  sun(PaintKey.hi);

  const RatingIcon(this.fill);

  /// The paint a checked icon is filled with.
  final PaintKey fill;
}

/// Rating recipe params.
///
/// Mirrors `RatingParams` in `src/lib/ink/recipes/rating-ink.ts`.
final class RatingParams {
  /// Params.
  const RatingParams({this.icon, this.disabled, this.invalid});

  final RatingIcon? icon;
  final bool? disabled;
  final bool? invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (icon case final RatingIcon i) 'icon': i.name,
    if (disabled case final bool d) 'disabled': d,
    if (invalid case final bool i) 'invalid': i,
  };
}

List<Pt> _starPoly(double cx, double cy, double rad) => [
  for (var i = 0; i < 10; i++)
    () {
      final a = -JsMath.pi / 2 + (i * tau) / 10;
      final r = switch (i % 2) {
        0 => rad,
        _ => rad * 0.46,
      };
      return (cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r);
    }(),
];

List<Pt> _heartPts(
  double cx,
  double cy,
  double rad, [
  double t0 = 0,
  double t1 = tau,
  int n = 44,
]) {
  final pts = <Pt>[];
  for (var i = 0; i <= n; i++) {
    final t = t0 + ((t1 - t0) * i) / n;
    final x = 16 * JsMath.pow(JsMath.sin(t), 3);
    final y =
        -(13 * JsMath.cos(t) -
            5 * JsMath.cos(2 * t) -
            2 * JsMath.cos(3 * t) -
            JsMath.cos(4 * t));
    pts.add((
      cx + (x / 17) * rad * 1.02,
      cy + (y / 17) * rad * 0.98 + rad * 0.06,
    ));
  }
  return pts;
}

List<Pt> _discPoly(double cx, double cy, double r, [int n = 24]) => [
  for (var i = 0; i < n; i++)
    (
      cx + JsMath.cos((i / n) * tau) * r,
      cy + JsMath.sin((i / n) * tau) * r,
    ),
];

List<Pt> _clipX(List<Pt> poly, double at, bool keepLow) {
  bool inside(Pt p) => switch (keepLow) {
    true => p.x <= at,
    false => p.x >= at,
  };
  final out = <Pt>[];
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final ia = inside(a);
    final ib = inside(b);
    if (ia) out.add(a);
    if (ia != ib) {
      final t = (at - a.x) / (b.x - a.x);
      out.add((at, a.y + t * (b.y - a.y)));
    }
  }
  return out;
}

List<Line> _outlineLines(
  Ink ink,
  RatingIcon icon,
  double cx,
  double cy,
  double rad, [
  bool filled = false,
]) {
  final rng = ink.next('outline');
  if (icon == RatingIcon.star && filled) {
    final pts = _starPoly(cx, cy + rad * 0.05, rad * 1.02);
    pts.addAll([pts[0], (pts[1].x + rng.gauss(0, 0.1), pts[1].y)]);
    return [
      Line(
        pts,
        o: const StrokeOpts(
          poly: true,
          start: StrokeStart.pool,
          end: StrokeEnd.flick,
          wobble: 0.5,
        ),
      ),
    ];
  }
  if (icon == RatingIcon.star) {
    return starLines(rng, cx, cy + rad * 0.05, rad * 1.02);
  }
  if (icon == RatingIcon.heart) {
    final heart = _heartPts(cx, cy, rad, 0.06, tau + 0.16);
    final pts = [
      for (final (i, p) in heart.indexed)
        (p.x + rng.gauss(0, 0.12) * (i / heart.length), p.y),
    ];
    return [
      Line(
        pts,
        o: const StrokeOpts(
          start: StrokeStart.pool,
          end: StrokeEnd.flick,
          wobble: 0.6,
        ),
      ),
    ];
  }
  final r = rad * 0.5;
  return [
    ...loopLines(rng.fork('disc'), cx, cy, r, r, turns: 1.1),
    ...burstLines(rng.fork('rays'), cx, cy, rad * 1.02, rays: 9),
  ];
}

/// A rating icon (star, heart or sun): a pencil outline at rest, filled
/// when checked, half filled when indeterminate.
///
/// Mirrors `ratingRecipe` in `src/lib/ink/recipes/rating-ink.ts`.
final Recipe<RatingParams> ratingRecipe = defineRecipe<RatingParams>(
  id: 'rating',
  kind: 'rating',
  layers: const [
    LayerName.rest,
    LayerName.checked,
    LayerName.indeterminate,
    LayerName.focus,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, RatingParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final icon = params.icon ?? RatingIcon.star;
  final disabled = params.disabled ?? false;
  final invalid = params.invalid ?? false;
  final s = math.min(w, h);
  final cx = w / 2;
  final cy = h / 2;
  final rad = s / 2 - 1.6;
  final calm = ctx.calm;
  final rtl = ctx.dir == Dir.rtl;
  if (!disabled) {
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, 0, 0, w, h, shape: FocusShape.ellipse, gap: 3),
    );
  }
  if (ctx.lazyOnly) return;

  final fine = s < 22;
  final restPen = switch ((disabled, invalid)) {
    (true, _) => PenName.pencilFine,
    (false, true) => PenName.red,
    (false, false) => PenName.pencil,
  };
  final feltPen = switch ((disabled, calm, fine)) {
    (true, _, _) => PenName.pencil,
    (false, true, _) => PenName.pencilFine,
    (false, false, true) => PenName.inkFine,
    (false, false, false) => PenName.ink,
  };
  void blob(List<Pt> poly) {
    ink.part('fill', () {
      if (disabled) {
        return wash(
          ink,
          poly,
          PaintKey.pencilMark,
          alpha: 0.4,
          material: Material.wash,
        );
      }
      return blobFill(
        ink,
        poly,
        icon.fill,
        alpha: switch (icon) {
          RatingIcon.heart => 0.84,
          _ => 0.9,
        },
        mis: clamp(s * 0.05, 0.6, 1.6),
      );
    });
  }

  List<Pt> body() => switch (icon) {
    RatingIcon.star => _starPoly(cx, cy + rad * 0.05, rad),
    RatingIcon.heart => _heartPts(cx, cy, rad),
    RatingIcon.sun => _discPoly(cx, cy, rad * 0.52),
  };

  ink
    ..layer(LayerName.rest, () {
      void empty() => ink.lines(
        _outlineLines(ink, icon, cx, cy, rad),
        restPen,
        StrokeOpts(
          width: switch (disabled) {
            true => 0.9,
            false => 1,
          },
          alpha: switch (disabled) {
            true => 0.6,
            false => 0.95,
          },
          simple: s < 40,
        ),
      );
      if (invalid && !disabled) {
        ink.group(GroupAttrs(hideOn: 'checked indeterminate'), empty);
        return;
      }
      empty();
    })
    ..layer(LayerName.checked, () {
      blob(body());
      ink.lines(
        _outlineLines(ink, icon, cx, cy, rad, true),
        feltPen,
        StrokeOpts(simple: s < 30),
      );
    })
    ..layer(LayerName.indeterminate, () {
      final half = _clipX(body(), cx, !rtl);
      blob(half);
      ink.lines(
        _outlineLines(ink, icon, cx, cy, rad, true),
        feltPen,
        StrokeOpts(alpha: 0.9, simple: s < 30),
      );
      if (!calm) {
        ink.stroke(
          seg(cx + 0.2, cy - rad * 0.55, cx - 0.2, cy + rad * 0.7, 0.3, 3),
          PenName.pencilFine,
          const StrokeOpts(
            alpha: 0.5,
            start: StrokeStart.soft,
            end: StrokeEnd.soft,
            wobble: 0.3,
            simple: true,
          ),
        );
      }
    });
}
