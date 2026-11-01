import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/props/prop_support.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A fastener prop.
///
/// Mirrors `FastenerKind` in `src/lib/ink/paper/props.ts`.
enum FastenerKind {
  clip('clip'),
  pin('pin'),
  staple('staple'),
  binderClip('binder-clip');

  const FastenerKind(this.id);

  /// The upstream name, e.g. `binder-clip`.
  final String id;
}

/// A paper clip [height] px tall, tilted by [angle] degrees (seeded when
/// null), steel or an accent [tone].
///
/// Mirrors `clip` in `src/lib/ink/paper/props.ts`.
InkResult paperClip(
  Object seed, {
  Tier? tier,
  bool? calm,
  double height = 64,
  Accent? tone,
  double? angle,
}) {
  final ink = propInk(seed, tier, calm);
  final hh = height;
  final w = hh / 3.4;
  final r = ink.next('clip');
  final tilt = angle ?? clamp(r.gauss(0, 2.4), -4, 4);
  final lw = clamp(w * 0.13, 1.1, 2.6);
  double j() => r.gauss(0, 0.012);
  String u(double x, double y) =>
      '${num10((x + j()) * w)} ${num10((y + j()) * w)}';
  String rad(double v) => num10(v * w);
  final d =
      'M${u(0, 0.95)}V${num10((2.9 + j()) * w)}A${rad(0.5)} ${rad(0.5)} 0 0 0 ${u(1, 2.9)}V${num10((0.4 + j()) * w)}A${rad(0.4)} ${rad(0.4)} 0 0 0 ${u(0.2, 0.4)}'
      'V${num10((2.6 + j()) * w)}A${rad(0.3)} ${rad(0.3)} 0 0 0 ${u(0.8, 2.6)}V${num10((1.2 + j()) * w)}';
  final steel = tone == null;
  final base = tok(tone?.name ?? 'pencil');
  final cx = w / 2, cy = hh / 2;
  final s = StringBuffer(pathTag(d, stroke: base, sw: lw));
  if (steel) s.write(pathTag(d, stroke: tok('sky'), sw: lw, op: 0.16));
  s.write(
    pathTag(
      d,
      stroke: tok('ink'),
      sw: lw * 0.4,
      op: switch (steel) {
        true => 0.5,
        false => 0.28,
      },
      transform: 'translate(${num10(lw * 0.22)} ${num10(lw * 0.14)})',
    ),
  );
  s.write(
    pathTag(
      d,
      stroke: tok('photo'),
      sw: lw * 0.32,
      op: 0.9,
      transform: 'translate(${num10(-lw * 0.2)} ${num10(-lw * 0.22)})',
    ),
  );
  ink.raw(
    '<g transform="rotate(${n(tilt)} ${num10(cx)} ${num10(cy)})">$s</g>',
    Material.top,
  );
  ink.grow(BBox(-lw, -lw, w + lw, hh + lw));
  return ink.toSvg(
    w: w,
    h: hh,
    pad: (lw * 2 + tilt.abs() * 0.4).ceilToDouble(),
  );
}

/// A push pin with a [size] px head in [color].
///
/// Mirrors `pin` in `src/lib/ink/paper/props.ts`.
InkResult pushPin(
  Object seed, {
  Tier? tier,
  bool? calm,
  double size = 24,
  Accent color = Accent.tomato,
}) {
  final ink = propInk(seed, tier, calm);
  final rr = size / 2;
  final w = size * 1.1, h = size * 1.4;
  final r = ink.next('pin');
  final cx = w / 2, cy = rr + 1;
  final col = tok(color.name);
  final tilt = r.range(-6, 6);
  final s = StringBuffer()
    ..write(
      pathTag(
        'M${num10(cx - rr * 0.16)} ${num10(cy + rr * 0.6)}L${num10(cx + rr * 0.05)} ${num10(cy + rr * 1.35)}',
        stroke: tok('pencil'),
        sw: rr * 0.24,
      ),
    )
    ..write(
      pathTag(
        'M${num10(cx - rr * 0.2)} ${num10(cy + rr * 0.6)}L${num10(cx - rr * 0.01)} ${num10(cy + rr * 1.33)}',
        stroke: tok('photo'),
        sw: rr * 0.08,
        op: 0.7,
      ),
    )
    ..write(
      '<ellipse cx="${num10(cx)}" cy="${num10(cy + rr * 0.56)}" rx="${num10(rr * 1.02)}" ry="${num10(rr * 0.4)}" fill="${tok('pencil')}"/>',
    )
    ..write(
      '<ellipse cx="${num10(cx - rr * 0.1)}" cy="${num10(cy + rr * 0.5)}" rx="${num10(rr * 0.9)}" ry="${num10(rr * 0.28)}" fill="${tok('photo')}" fill-opacity=".5"/>',
    );
  final dome = circleD(cx, cy, rr * 0.94);
  final cid = ink.clipDef(dome);
  s
    ..write(pathTag(dome, fill: col))
    ..write(
      '<g clip-path="url(#$cid)">'
      '${pathTag(circleD(cx + rr * 0.42, cy + rr * 0.46, rr * 0.98), fill: tok('ink'), op: 0.24)}'
      '${pathTag(circleD(cx + rr * 0.5, cy + rr * 0.55, rr * 0.86), fill: tok('ink'), op: 0.1)}</g>',
    )
    ..write(pathTag(dome, stroke: tok('ink'), sw: 0.8, op: 0.4))
    ..write(
      '<ellipse cx="${num10(cx - rr * 0.34)}" cy="${num10(cy - rr * 0.38)}" rx="${num10(rr * 0.3)}" ry="${num10(rr * 0.2)}" fill="${tok('photo')}" fill-opacity=".8" transform="rotate(-38 ${num10(cx - rr * 0.34)} ${num10(cy - rr * 0.38)})"/>',
    )
    ..write(
      pathTag(
        circleD(cx - rr * 0.06, cy - rr * 0.62, rr * 0.06),
        fill: tok('photo'),
        op: 0.9,
      ),
    );
  ink.raw(
    '<g transform="rotate(${n(tilt)} ${num10(cx)} ${num10(cy)})">$s</g>',
    Material.top,
  );
  ink.grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 3);
}

/// A staple [length] px long, or two when [doubled] (upstream `double`).
///
/// Mirrors `staple` in `src/lib/ink/paper/props.ts`.
InkResult staple(
  Object seed, {
  Tier? tier,
  bool? calm,
  double length = 20,
  bool doubled = false,
}) {
  final ink = propInk(seed, tier, calm);
  final l = length;
  final w = l + 4;
  final h = switch (doubled) {
    true => 14.0,
    false => 8.0,
  };
  final r = ink.next('staple');
  String one(double yy, double rot) {
    final x0 = 2 + r.range(-0.2, 0.2);
    final g = StringBuffer()
      ..write(
        pathTag(
          'M${num10(x0)} ${num10(yy)}V${num10(yy + 2.4)}M${num10(x0 + l)} ${num10(yy)}V${num10(yy + 2.4)}',
          stroke: tok('ink'),
          sw: 1.5,
          op: 0.55,
        ),
      )
      ..write(
        pathTag(
          'M${num10(x0)} ${num10(yy + 0.9)}H${num10(x0 + l)}',
          stroke: tok('ink'),
          sw: 1.9,
          op: 0.18,
        ),
      )
      ..write(
        pathTag(
          'M${num10(x0)} ${num10(yy)}H${num10(x0 + l)}',
          stroke: tok('pencil'),
          sw: 2.4,
        ),
      )
      ..write(
        pathTag(
          'M${num10(x0 + 0.8)} ${num10(yy - 0.55)}H${num10(x0 + l - 0.8)}',
          stroke: tok('photo'),
          sw: 0.9,
          op: 0.9,
        ),
      );
    return '<g transform="rotate(${n(rot)} ${num10(x0 + l / 2)} ${num10(yy)})">$g</g>';
  }

  final s = StringBuffer(one(2.4, r.range(-5, 5)));
  if (doubled) s.write(one(9, r.range(-5, 5)));
  ink.raw('$s', Material.top);
  ink.grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 3);
}

/// A binder clip [width] px wide.
///
/// Mirrors `binderClip` in `src/lib/ink/paper/props.ts`.
InkResult binderClip(
  Object seed, {
  Tier? tier,
  bool? calm,
  double width = 52,
}) {
  final ink = propInk(seed, tier, calm);
  final w = width;
  final h = w * 1.14;
  final r = ink.next('binder');
  double j() => r.gauss(0, 0.6);
  final by = h * 0.4;
  ink.raw(
    pathTag(
          'M${num10(w * 0.27)} ${num10(by + 2)}C${num10(w * 0.02 + j())} ${num10(h * 0.16)} ${num10(w * 0.16)} ${num10(1.5)} ${num10(w * 0.34)} ${num10(1.5 + j() * 0.3)}C${num10(w * 0.5)} ${num10(1.5)} ${num10(w * 0.5)} ${num10(h * 0.2)} ${num10(w * 0.45)} ${num10(by + 2)}',
          stroke: tok('pencil'),
          sw: 2.1,
        ) +
        pathTag(
          'M${num10(w * 0.55)} ${num10(by + 2)}C${num10(w * 0.5 + j())} ${num10(h * 0.2)} ${num10(w * 0.5)} ${num10(1.5)} ${num10(w * 0.66)} ${num10(1.5 + j() * 0.3)}C${num10(w * 0.84)} ${num10(1.5)} ${num10(w * 0.98 + j())} ${num10(h * 0.16)} ${num10(w * 0.73)} ${num10(by + 2)}',
          stroke: tok('pencil'),
          sw: 2.1,
        ) +
        pathTag(
          'M${num10(w * 0.25)} ${num10(h * 0.16)}C${num10(w * 0.2)} ${num10(h * 0.06)} ${num10(w * 0.3)} ${num10(2.6)} ${num10(w * 0.36)} ${num10(2.6)}',
          stroke: tok('photo'),
          sw: 0.8,
          op: 0.85,
        ) +
        pathTag(
          'M${num10(w * 0.64)} ${num10(2.6)}C${num10(w * 0.72)} ${num10(2.6)} ${num10(w * 0.8)} ${num10(h * 0.06)} ${num10(w * 0.79)} ${num10(h * 0.14)}',
          stroke: tok('photo'),
          sw: 0.8,
          op: 0.85,
        ),
    Material.under,
  );
  final body = <Pt>[
    (w * 0.2, by),
    (w * 0.8, by),
    (w * 0.98 + j() * 0.4, h * 0.96),
    (w * 0.02 + j() * 0.4, h * 0.96),
  ];
  final bodyPts = _densifyRound(body, 4.5);
  ink.raw(
    pathTag(polyD(bodyPts, true), fill: tok('ink'), op: 0.96),
    Material.wash,
  );
  ink.stroke(
    [...bodyPts, bodyPts[0]],
    PenName.inkBrush,
    const StrokeOpts(width: 0.55, wobble: 0.5),
  );
  ink.raw(
    pathTag(
          'M${num10(w * 0.1)} ${num10(h * 0.84)}H${num10(w * 0.9)}',
          stroke: tok('pencil'),
          sw: 1.2,
          op: 0.5,
        ) +
        pathTag(
          'M${num10(w * 0.24)} ${num10(by + 3)}H${num10(w * 0.76)}',
          stroke: tok('photo'),
          sw: 1.2,
          op: 0.3,
        ) +
        pathTag(
          'M${num10(w * 0.16)} ${num10(by + 6)}L${num10(w * 0.07)} ${num10(h * 0.8)}',
          stroke: tok('photo'),
          sw: 1.1,
          op: 0.2,
        ),
    Material.top,
  );
  ink.grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 3);
}

List<Pt> _densifyRound(List<Pt> v, double rad) {
  final out = <Pt>[];
  final m = v.length;
  for (var i = 0; i < m; i++) {
    final p = v[(i + m - 1) % m], c = v[i], nx = v[(i + 1) % m];
    final l1 = JsMath.or(JsMath.hypot(p.x - c.x, p.y - c.y), 1);
    final l2 = JsMath.or(JsMath.hypot(nx.x - c.x, nx.y - c.y), 1);
    final rr = math.min(math.min(rad, l1 * 0.4), l2 * 0.4);
    final a = (c.x + ((p.x - c.x) / l1) * rr, c.y + ((p.y - c.y) / l1) * rr);
    final b = (c.x + ((nx.x - c.x) / l2) * rr, c.y + ((nx.y - c.y) / l2) * rr);
    for (var k = 0; k <= 4; k++) {
      final t = k / 4, u = 1 - t;
      out.add((
        u * u * a.x + 2 * u * t * c.x + t * t * b.x,
        u * u * a.y + 2 * u * t * c.y + t * t * b.y,
      ));
    }
  }
  return out;
}
