import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/props/prop_support.dart';

/// Running stitches inside a [w]×[h] box: [inset] from the edge, corners
/// of [radius], stitches [stitch] long with [gap]s, in [color].
///
/// Mirrors `stitches` in `src/lib/ink/paper/props.ts`.
InkResult stitches(
  Object seed,
  double w,
  double h, {
  Tier? tier,
  bool? calm,
  double inset = 8,
  double radius = 6,
  PaintKey color = PaintKey.marker,
  double stitch = 7,
  double gap = 4,
}) {
  final ink = propInk(seed, tier, calm);
  final r = ink.next('stitch');
  final rad = math.min(radius, (math.min(w, h) - 2 * inset) / 2);
  final outline = roundRectPoly(
    inset,
    inset,
    w - 2 * inset,
    h - 2 * inset,
    math.max(0, rad),
  );
  final rs = resample([...outline, outline[0]], 0.8);
  final total = rs.length;
  final d = StringBuffer();
  var u = r.range(0, 3);
  Pt at(double sArc) {
    final step = total / (rs.x.length - 1);
    final f = math.min(rs.x.length - 2, math.max(0, (sArc / step).floor()));
    final t = math.min(1.0, math.max(0.0, sArc / step - f));
    return (
      rs.x[f] + (rs.x[f + 1] - rs.x[f]) * t,
      rs.y[f] + (rs.y[f + 1] - rs.y[f]) * t,
    );
  }

  while (u < total - stitch) {
    final l = stitch * r.range(0.92, 1.05);
    final off = r.gauss(0, 0.3);
    final pts = <Pt>[];
    for (var k = 0; k <= 3; k++) {
      final p0 = at(u + (l * k) / 3);
      final p1 = at(math.min(total - 0.2, u + (l * k) / 3 + 0.6));
      final tx = p1.x - p0.x, ty = p1.y - p0.y;
      final len = JsMath.or(JsMath.hypot(tx, ty), 1);
      final x = p0.x - (ty / len) * off + r.gauss(0, 0.06);
      pts.add((x, p0.y + (tx / len) * off + r.gauss(0, 0.06)));
    }
    d.write(polyD(pts));
    u += stitch + gap + r.gauss(0, 0.5);
  }
  final id = 'll-st${seedTag(ink)}';
  String line(String stroke, double sw, double op, String tf) {
    final transform = switch (tf.isEmpty) {
      true => '',
      false => ' transform="$tf"',
    };
    return '<use href="#$id" fill="none" stroke="$stroke" stroke-width="${js(sw)}" stroke-opacity="${js(op)}" stroke-linecap="round" stroke-linejoin="round"$transform/>';
  }

  ink.raw(
    '<defs><path id="$id" d="$d"/></defs>'
    '${line(tok('ink'), 2.1, 0.16, 'translate(.4 .8)')}'
    '${line(tok(color.id), 1.8, 1, '')}'
    '${line(tok('photo'), 0.55, 0.4, 'translate(-.3 -.35)')}',
    Material.top,
  );
  ink.grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 2);
}

/// A rubber band crossing a [w]×[h] box, in [color].
///
/// Mirrors `rubberBand` in `src/lib/ink/paper/props.ts`.
InkResult rubberBand(
  Object seed,
  double w,
  double h, {
  Tier? tier,
  bool? calm,
  Accent color = Accent.tangerine,
}) {
  final ink = propInk(seed, tier, calm);
  final r = ink.next('band');
  final g = w * 0.74;
  double bow() => r.gauss(0, 0.6);
  String run(double a, double b) =>
      'M${num10(a + bow())} -4C${num10(a)} ${num10(h * 0.3)} ${num10(b)} ${num10(h * 0.36)} ${num10(b + bow())} ${num10(h * 0.5)}'
      'S${num10(a)} ${num10(h * 0.7)} ${num10(a + bow())} ${num10(h + 4)}';
  final d1 = run((w - g) / 2, (w + g) / 2);
  final d2 = run((w + g) / 2, (w - g) / 2);
  final sw = clamp(w * 0.22, 3.5, 7);
  final col = tok(color.name);
  ink.raw(
    pathTag(
          d1 + d2,
          stroke: tok('ink'),
          sw: sw + 1,
          op: 0.16,
          transform: 'translate(.8 1.6)',
        ) +
        pathTag(d1, stroke: col, sw: sw, op: 0.94) +
        pathTag(d2, stroke: col, sw: sw, op: 0.94) +
        pathTag(
          d1 + d2,
          stroke: tok('ink'),
          sw: sw * 0.22,
          op: 0.2,
          transform: 'translate(.7 .8)',
        ) +
        pathTag(
          d1 + d2,
          stroke: tok('photo'),
          sw: sw * 0.2,
          op: 0.5,
          transform: 'translate(${num10(-sw * 0.2)} ${num10(-sw * 0.22)})',
        ),
    Material.top,
  );
  ink.grow(BBox(-2, -4, w + 2, h + 4));
  return ink.toSvg(w: w, h: h, pad: 6);
}

/// A faint coffee ring of [radius] px.
///
/// Mirrors `coffeeRing` in `src/lib/ink/paper/props.ts`.
InkResult coffeeRing(
  Object seed, {
  Tier? tier,
  bool? calm,
  double radius = 48,
}) {
  final ink = propInk(seed, tier, calm);
  final r0 = radius;
  final r = ink.next('ring');
  final p1 = r.range(0, tau), p2 = r.range(0, tau);
  final gapC = r.range(0, tau), gapW = r.range(0.35, 0.8);
  Pt pt(double a, double big) {
    final rr =
        big *
        (1 + 0.008 * JsMath.sin(2 * a + p1) + 0.005 * JsMath.sin(3 * a + p2));
    return (r0 + JsMath.cos(a) * rr, r0 + JsMath.sin(a) * rr * 0.98);
  }

  List<Pt> arc(double big, double a0, double a1) {
    final steps = math.max(8, (((a1 - a0) * big) / 3).ceil());
    return [
      for (var i = 0; i <= steps; i++) pt(a0 + ((a1 - a0) * i) / steps, big),
    ];
  }

  final s = StringBuffer()
    ..write(pathTag(circleD(r0, r0, r0 * 0.965), fill: tok('kraft'), op: 0.05))
    ..write(
      pathTag(circleD(r0, r0, r0 - 2), stroke: tok('kraft'), sw: 4, op: 0.16),
    )
    ..write(
      pathTag(
        polyD(arc(r0 - 1, gapC + gapW, gapC + tau - gapW)),
        stroke: tok('orange-text'),
        sw: 1.4,
        op: 0.3,
      ),
    );
  ink.raw('<g style="mix-blend-mode:var(--ll-blend)">$s</g>', Material.top);
  ink.grow(BBox(0, 0, r0 * 2, r0 * 2));
  return ink.toSvg(w: r0 * 2, h: r0 * 2, pad: 3);
}

/// The markup of a sticky note's curled corner of size [c], ids from [id].
///
/// Mirrors `curlMarkup` in `src/lib/ink/paper/props.ts`.
String curlMarkup(
  Rng r,
  String id,
  double c, [
  PaintKey color = PaintKey.stickyYellow,
]) {
  final col = tok(color.id);
  double jt() => r.gauss(0, 0.2);
  final Pt a = (0.2, c + jt());
  final Pt b = (c + jt(), 0.2);
  final mx = c * (0.42 + jt() * 0.05);
  final Pt m = (mx, c * (0.42 + jt() * 0.05));
  final s = StringBuffer()
    ..write(
      '<linearGradient id="${id}s" gradientUnits="userSpaceOnUse" x1="${num10(m.x)}" y1="${num10(m.y)}" x2="${num10(m.x - c * 0.16)}" y2="${num10(m.y - c * 0.16)}">'
      '<stop offset="0" stop-color="${tok('ink')}" stop-opacity=".16"/><stop offset="1" stop-color="${tok('ink')}" stop-opacity="0"/></linearGradient>',
    )
    ..write(
      pathTag(
        polyD([
          (a.x - c * 0.12, a.y - c * 0.12 + 2),
          (b.x - c * 0.12 + 2, b.y - c * 0.12),
          (m.x - c * 0.16, m.y - c * 0.16),
        ], true),
        fill: 'url(#${id}s)',
      ),
    )
    ..write(
      '<linearGradient id="${id}d" gradientUnits="userSpaceOnUse" x1="${num10(c / 2)}" y1="${num10(c / 2)}" x2="${num10(c * 0.86)}" y2="${num10(c * 0.86)}">'
      '<stop offset="0" stop-color="${tok('ink')}" stop-opacity=".32"/><stop offset="1" stop-color="${tok('ink')}" stop-opacity="0"/></linearGradient>',
    )
    ..write(pathTag(polyD([a, b, (c + 1, c + 1)], true), fill: 'url(#${id}d)'))
    ..write(
      '<linearGradient id="$id" gradientUnits="userSpaceOnUse" x1="${num10(c / 2)}" y1="${num10(c / 2)}" x2="${num10(m.x)}" y2="${num10(m.y)}">'
      '<stop offset="0" stop-color="${tok('photo')}" stop-opacity=".95"/><stop offset="1" stop-color="$col" stop-opacity=".98"/></linearGradient>',
    )
    ..write(pathTag(polyD([a, b, m], true), fill: 'url(#$id)'))
    ..write(pathTag(polyD([a, m, b]), stroke: tok('ink'), sw: 0.6, op: 0.24))
    ..write(pathTag(polyD([a, b]), stroke: tok('photo'), sw: 0.9, op: 0.75));
  return '$s';
}

/// A sticky note's curled corner of size [c] as a prop.
///
/// Mirrors `stickyCurl` in `src/lib/ink/paper/props.ts`.
InkResult stickyCurl(
  Object seed,
  double c, {
  Tier? tier,
  bool? calm,
  PaintKey color = PaintKey.stickyYellow,
}) {
  final ink = propInk(seed, tier, calm);
  ink.raw(
    curlMarkup(ink.next('curl'), 'll-cu${seedTag(ink)}', c, color),
    Material.top,
  );
  ink.grow(BBox(0, 0, c, c));
  return ink.toSvg(w: c, h: c, pad: 3);
}

/// A wooden ruler [length] px long and [height] px tall.
///
/// Mirrors `ruler` in `src/lib/ink/paper/props.ts`.
InkResult rulerProp(
  Object seed,
  double length, {
  Tier? tier,
  bool? calm,
  double height = 30,
}) {
  final ink = propInk(seed, tier, calm);
  final h = height;
  final r = ink.next('ruler');
  final body = polyD([
    (0.6, 0.5 + r.gauss(0, 0.15)),
    (length * 0.5, 0.2 + r.gauss(0, 0.2)),
    (length - 0.6, 0.5 + r.gauss(0, 0.15)),
    (length - 0.4, h - 0.5),
    (length * 0.5, h - 0.2 + r.gauss(0, 0.2)),
    (0.5, h - 0.6),
  ], true);
  final d = StringBuffer();
  var i = 0;
  for (var x = 6.0; x < length - 5; i++, x += 6) {
    final tick = switch (i % 5 == 0) {
      true => h * 0.4,
      false => h * 0.22,
    };
    final at = num10(x + r.gauss(0, 0.08));
    d.write('M$at 0.8v${num10(tick + r.gauss(0, 0.4))}');
  }
  ink.raw(
    pathTag(body, fill: tok('kraft'), op: 0.96) +
        pathTag(
          'M1 ${num10(h * 0.82)}H${num10(length - 1)}',
          stroke: tok('orange-text'),
          sw: 0.6,
          op: 0.18,
        ) +
        pathTag(
          'M1 1.1H${num10(length - 1)}',
          stroke: tok('photo'),
          sw: 1,
          op: 0.65,
        ) +
        pathTag('$d', stroke: tok('ink'), sw: 0.9, op: 0.78) +
        pathTag(body, stroke: tok('ink'), sw: 0.7, op: 0.32),
    Material.top,
  );
  ink.grow(BBox(0, 0, length, h));
  return ink.toSvg(w: length, h: h, pad: 3);
}
