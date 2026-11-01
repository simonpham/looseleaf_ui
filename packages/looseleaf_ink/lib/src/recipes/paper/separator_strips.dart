import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A point [t] along a separator, [u] across it.
typedef SeparatorAt = Pt Function(double t, [double u]);

/// Ruler dashes along a [len] long separator.
///
/// Mirrors `dashes` in `src/lib/ink/recipes/separator-ink.ts`.
List<Line> separatorDashes(double len, SeparatorAt at) {
  const gap = 5.0;
  final count = math.max(1, JsMath.roundInt((len + gap) / 17));
  final step = (len + gap) / count;
  return [
    for (var i = 0; i < count; i++)
      Line([at(i * step), at(i * step + step - gap)], o: ruler),
  ];
}

/// A wandering wave along a [len] long separator, in two strokes past
/// 300 px.
///
/// Mirrors `wave` in `src/lib/ink/recipes/separator-ink.ts`.
List<Line> separatorWave(Rng rng, double len, SeparatorAt at) {
  const amp = 1.7;
  const wl = 13.0;
  final p1 = rng.range(0, tau), p2 = rng.range(0, tau), p3 = rng.range(0, tau);
  var ph = rng.range(0, tau);
  List<Pt> build(double a, double b) {
    final pts = <Pt>[];
    for (var t = a; t <= b; t += 2.3) {
      ph +=
          (2.3 / wl) *
          tau *
          (1 + 0.22 * JsMath.sin(t / 37 + p1) + 0.1 * JsMath.sin(t / 11 + p2));
      final k = amp * (0.75 + 0.25 * JsMath.sin(t / 53 + p3));
      pts.add(at(t, JsMath.sin(ph) * k));
    }
    return pts;
  }

  if (len > 300) {
    final m = len * rng.range(0.46, 0.6);
    return [
      Line(
        build(0, m + 3),
        o: const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.soft,
          wobble: 0.5,
          speed: 1.1,
          simple: true,
        ),
      ),
      Line(
        build(m - 3, len),
        o: const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          wobble: 0.5,
          speed: 1.1,
          simple: true,
        ),
      ),
    ];
  }
  return [
    Line(
      build(0, len),
      o: const StrokeOpts(
        end: StrokeEnd.flick,
        wobble: 0.5,
        speed: 1.1,
        simple: true,
      ),
    ),
  ];
}

/// Felt dots along a [len] long separator.
///
/// Mirrors `dots` in `src/lib/ink/recipes/separator-ink.ts`.
void separatorDots(Ink ink, double len, SeparatorAt at) {
  const r = 1.15;
  final count = math.max(1, JsMath.roundInt((len - 2 * r) / 6.5));
  final step = (len - 2 * r) / count;
  final d = StringBuffer();
  for (var i = 0; i <= count; i++) {
    final (cx, cy) = at(r + i * step);
    d.write(
      'M${num10(cx - r)} ${num10(cy)}a${js(r)} ${js(r)} 0 1 0 ${js(2 * r)} 0'
      'a${js(r)} ${js(r)} 0 1 0 ${js(-2 * r)} 0Z',
    );
  }
  ink
    ..flat(Material.felt, '$d', PaintKey.ink, op: 0.86)
    ..grow(BBox(0, -3, len, 3));
}

/// A strip of kraft tape across the separator.
///
/// Mirrors `tapeStrip` in `src/lib/ink/recipes/separator-ink.ts`.
void tapeStrip(
  Ink ink,
  double len,
  double c,
  bool vertical,
  Tier tier,
  bool calm,
) {
  const th = 10.0;
  final rng = ink.next('tape');
  final length = math.max(24, len).toDouble();
  final res = tape(
    '${ink.seed}|strip',
    kind: TapeKind.kraft,
    length: length,
    height: th,
    ends: TapeEnds.saw,
    tier: tier,
    calm: calm,
  );
  final skew = rng.gauss(0, 0.25);
  final tf = switch (vertical) {
    true => 'translate(${num10(c + th / 2)} 0) rotate(${num10(90 + skew)} 0 0)',
    false =>
      'translate(0 ${num10(c - th / 2)}) '
          'rotate(${num10(skew)} ${num10(len / 2)} ${num10(th / 2)})',
  };
  ink.group(GroupAttrs(transform: tf), () {
    ink
      ..raw(
        '<rect x=".6" y="1.4" width="${num10(length)}" height="${js(th)}" '
        'fill="var(--ll-ink)" fill-opacity=".12"/>',
        Material.under,
      )
      ..raw(res.svg, Material.top);
  });
  ink.grow(switch (vertical) {
    true => BBox(c - th, 0, c + th, len),
    false => BBox(0, c - th, len, c + th),
  });
}

/// A run of marker stitches along the separator.
///
/// Mirrors `stitchLine` in `src/lib/ink/recipes/separator-ink.ts`.
void stitchLine(Ink ink, double len, SeparatorAt at) {
  const gap = 4.2;
  final count = math.max(1, JsMath.roundInt((len - 2 + gap) / (6.4 + gap)));
  final step = (len - 2 + gap) / count;
  final d = StringBuffer();
  for (var i = 0; i < count; i++) {
    final (ax, ay) = at(1 + i * step);
    final (bx, by) = at(1 + i * step + step - gap);
    d.write('M${num10(ax)} ${num10(ay)}L${num10(bx)} ${num10(by)}');
  }
  final id = 'll-sr${ink.seed.toRadixString(36)}';
  String pass(String stroke, double sw, double op, String tf) {
    final transform = switch (tf.isEmpty) {
      true => '',
      false => ' transform="$tf"',
    };
    return '<use href="#$id" fill="none" stroke="$stroke" '
        'stroke-width="${js(sw)}" stroke-opacity="${js(op)}" '
        'stroke-linecap="round" stroke-linejoin="round"$transform/>';
  }

  ink.raw(
    '<defs><path id="$id" d="$d"/></defs>'
    '${pass('var(--ll-ink)', 2.1, 0.16, 'translate(.4 .8)')}'
    '${pass('var(--ll-marker)', 1.8, 1, '')}'
    '${pass('var(--ll-photo)', 0.55, 0.4, 'translate(-.3 -.35)')}',
    Material.top,
  );
  final (x0, y0) = at(0, -3);
  final (x1, y1) = at(len, 3);
  ink.grow(
    BBox(
      math.min(x0, x1),
      math.min(y0, y1),
      math.max(x0, x1),
      math.max(y0, y1),
    ),
  );
}

/// A strip of torn paper across the separator.
///
/// Mirrors `tornStrip` in `src/lib/ink/recipes/separator-ink.ts`.
void tornStrip(Ink ink, double len, double c, bool vertical) {
  const th = 8.0;
  final rng = ink.next('torn');
  final o = sheetOutline(
    rng,
    math.max(20, len).toDouble(),
    th,
    const EdgeSpec(top: EdgeKind.torn, bottom: EdgeKind.torn),
    amp: 0.95 * ink.knobs.wobble,
  );
  Pt flip(Pt p) => switch (vertical) {
    true => (c - th / 2 + p.y, p.x),
    false => (p.x, c - th / 2 + p.y),
  };
  final moved = Outline(
    pts: o.pts.map(flip).toList(),
    rim: o.rim.map(flip).toList(),
    crisp: o.crisp,
    reach: o.reach,
    fibrous: o.fibrous,
    sides: o.sides,
  );
  final body = outlinePath(moved, OutlineRing.body, ink.tier);
  final rim = outlinePath(moved, OutlineRing.rim, ink.tier);
  final id = 'll-tr${ink.seed.toRadixString(36)}';
  final shadow = switch (vertical) {
    true => '1 .4',
    false => '.4 1.3',
  };
  ink
    ..raw(
      '<defs><path id="$id" d="$body"/></defs>'
      '<use href="#$id" fill="var(--ll-ink)" fill-opacity=".13" '
      'transform="translate($shadow)"/>'
      '<path d="$rim" fill="var(--ll-photo)" fill-opacity=".8"/>'
      '<use href="#$id" fill="var(--ll-paper-shade)"/>'
      '<use href="#$id" fill="none" stroke="var(--ll-ink)" '
      'stroke-opacity=".16" stroke-width=".6"/>',
      Material.top,
    )
    ..grow(switch (vertical) {
      true => BBox(c - th, 0, c + th, len),
      false => BBox(0, c - th, len, c + th),
    });
}
