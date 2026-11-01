import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/props/prop_support.dart';

/// A tape strip.
///
/// Mirrors `TapeKind` in `src/lib/ink/paper/props.ts`.
enum TapeKind {
  masking('masking'),
  washiDots('washi-dots'),
  washiStripes('washi-stripes'),
  washiZigzag('washi-zigzag'),
  washiGingham('washi-gingham'),
  kraft('kraft'),
  clear('clear');

  const TapeKind(this.id);

  /// The upstream name, e.g. `washi-dots`.
  final String id;

  /// How this tape is torn off by default (`ENDS_DEFAULT`).
  TapeEnds get defaultEnds => switch (this) {
    masking || kraft => TapeEnds.saw,
    clear => TapeEnds.straight,
    _ => TapeEnds.scissor,
  };
}

/// Every tape kind (`TAPE_KINDS`).
const List<TapeKind> tapeKinds = TapeKind.values;

/// How a tape's ends are cut.
///
/// Mirrors `TapeEnds` in `src/lib/ink/paper/props.ts`.
enum TapeEnds { saw, torn, straight, scissor }

Accent? _washiDefault(TapeKind kind) => switch (kind) {
  TapeKind.washiDots => Accent.bubblegum,
  TapeKind.washiStripes => Accent.tangerine,
  TapeKind.washiZigzag => Accent.grass,
  TapeKind.washiGingham => Accent.sky,
  _ => null,
};

List<Pt> _tapeEnd(TapeEnds kind, double x0, int dir, double h, Rng r) {
  final slant = r.range(-1.6, 1.6);
  Pt at(double y, double depth) => (x0 + dir * (depth + (slant * y) / h), y);
  final out = <Pt>[];
  switch (kind) {
    case TapeEnds.straight:
      return [at(0, 0.3), at(h, 0.3)];
    case TapeEnds.saw:
      final pitch = r.range(1.7, 2.3);
      var k = 0;
      for (var y = 0.0; y < h + 0.1; y += pitch, k++) {
        final yy = math.min(y, h);
        out.add(
          at(
            yy,
            switch (k % 2) {
              0 => 0.2,
              _ => r.range(0.8, 1.9),
            },
          ),
        );
      }
      return out;
    case TapeEnds.scissor:
      final cnt = math.max(2, JsMath.roundInt(h / 4.4));
      for (var k = 0; k <= cnt * 2; k++) {
        final y = (k / (cnt * 2)) * h;
        out.add(
          at(
            y,
            switch (k % 2) {
              0 => 0.15,
              _ => 1.8 + r.range(-0.15, 0.15),
            },
          ),
        );
      }
      return out;
    case TapeEnds.torn:
      final f = noise1(r, h, 3);
      for (var y = 0.0; y <= h + 0.1; y += 1.2) {
        out.add(at(math.min(y, h), 1.3 + 1.6 * f(y)));
      }
      return out;
  }
}

/// A strip of tape [length]×[height] px with seeded ends, print and
/// crinkles.
///
/// Mirrors `tape` in `src/lib/ink/paper/props.ts`.
InkResult tape(
  Object seed, {
  Tier? tier,
  bool? calm,
  TapeKind kind = TapeKind.masking,
  double length = 72,
  double height = 22,
  TapeEnds? ends,
  Accent? color,
}) {
  final ink = propInk(seed, tier, calm);
  final w = length;
  final h = height;
  final r = ink.next('tape');
  final cut = ends ?? kind.defaultEnds;
  final left = _tapeEnd(cut, 0.5, 1, h, r.fork('l'));
  final right = _tapeEnd(cut, w - 0.5, -1, h, r.fork('r')).reversed;
  final body = polyPath([...left, ...right], 10);
  final accent = (color ?? _washiDefault(kind) ?? Accent.bubblegum).name;
  final gid = 'll-tp${seedTag(ink)}';
  ink.group(GroupAttrs(clip: body), () {
    final s = StringBuffer(_base(kind, w, h, accent));
    final pr = r.fork('print');
    s.write(switch (kind) {
      TapeKind.washiDots => _dots(pr, w, h),
      TapeKind.washiStripes => _stripes(pr, w, h, accent),
      TapeKind.washiZigzag => _zigzag(pr, w, h, accent),
      TapeKind.washiGingham => _gingham(pr, w, h, accent),
      TapeKind.kraft => _kraftFibres(pr, w, h),
      _ => '',
    });
    final clear = kind == TapeKind.clear;
    s.write(_crinkles(r, w, h, clear));
    s.write(
      '<linearGradient id="$gid" x1="0" y1="0" x2="0" y2="1">'
      '<stop offset="0" stop-color="${tok('photo')}" stop-opacity=".0"/>'
      '<stop offset=".3" stop-color="${tok('photo')}" stop-opacity="${js(_pick(clear, 0.5, 0.24))}"/>'
      '<stop offset=".62" stop-color="${tok('photo')}" stop-opacity="0"/>'
      '<stop offset="1" stop-color="${tok('ink')}" stop-opacity=".05"/>'
      '</linearGradient>',
    );
    s.write('<rect width="${js(w)}" height="${js(h)}" fill="url(#$gid)"/>');
    s.write(
      pathTag(
        'M0 .5H${js(w)}M0 ${num10(h - 0.5)}H${js(w)}',
        stroke: tok('tape-edge'),
        sw: 0.7,
        op: _pick(clear, 1, 0.9),
        cap: 'butt',
      ),
    );
    s.write(
      pathTag(
        'M0 1.7H${js(w)}M0 ${num10(h - 1.7)}H${js(w)}',
        stroke: tok('photo'),
        sw: 0.6,
        op: 0.34,
        cap: 'butt',
      ),
    );
    if (kind == TapeKind.masking) {
      final fl = StringBuffer();
      for (var i = 0; i < JsMath.roundInt(w / 8); i++) {
        fl.write(
          'M${num10(r.range(2, w - 2))} ${num10(r.range(2, h - 2))}'
          'l${num10(r.range(1, 5))} ${num10(r.range(-0.6, 0.6))}',
        );
      }
      s.write(
        pathTag('$fl', stroke: tok('pencil-mark'), sw: 0.4, op: 0.28),
      );
    }
    ink.raw('$s', Material.top);
  });
  ink.grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 3);
}

double _pick(bool clear, double yes, double no) => switch (clear) {
  true => yes,
  false => no,
};

String _base(TapeKind kind, double w, double h, String accent) {
  final rect = 'M0 0H${js(w)}V${js(h)}H0Z';
  return switch (kind) {
    TapeKind.masking =>
      pathTag(rect, fill: tok('kraft'), op: 0.2) +
          pathTag(rect, fill: tok('tape')),
    TapeKind.kraft => pathTag(rect, fill: tok('kraft'), op: 0.9),
    TapeKind.clear => pathTag(rect, fill: tok('photo'), op: 0.16),
    TapeKind.washiDots => pathTag(rect, fill: tok(accent), op: 0.88),
    _ => pathTag(rect, fill: tok('photo'), op: 0.88),
  };
}

String _dots(Rng pr, double w, double h) {
  final big = StringBuffer(), small = StringBuffer();
  final gx = h * 0.34;
  var row = 0;
  for (var y = h * 0.2; y < h + gx; y += gx * 0.86, row++) {
    for (var x = (row % 2) * gx * 0.5 - gx * 0.2; x < w + gx; x += gx) {
      final jx = pr.gauss(0, 0.22), jy = pr.gauss(0, 0.22);
      if (row.isOdd) {
        small.write(circleD(x + jx, y + jy, h * 0.058 * pr.range(0.86, 1.14)));
        continue;
      }
      big.write(circleD(x + jx, y + jy, h * 0.105 * pr.range(0.88, 1.12)));
    }
  }
  return pathTag('$big', fill: tok('photo'), op: 0.94) +
      pathTag('$small', fill: tok('photo'), op: 0.78);
}

String _stripes(Rng pr, double w, double h, String accent) {
  final a = StringBuffer(), b = StringBuffer();
  for (var x = -h - 4; x < w + h;) {
    final sw = pr.range(2.6, 4.8);
    final p =
        'M${num10(x)} ${num10(h + 1)}L${num10(x + sw)} ${num10(h + 1)}'
        'L${num10(x + sw + h + 2)} -1L${num10(x + h + 2)} -1Z';
    final into = switch (pr() < 0.4) {
      true => b,
      false => a,
    };
    into.write(p);
    x += sw + pr.range(3.6, 5.6);
  }
  return pathTag('$a', fill: tok(accent), op: 0.9) +
      pathTag('$b', fill: tok(accent), op: 0.7);
}

String _zigzag(Rng pr, double w, double h, String accent) {
  final zz = StringBuffer();
  final amp = h * 0.075, step = h * 0.27;
  for (var row = 0; row < 3; row++) {
    final y0 = h * (0.22 + row * 0.28);
    final pts = <Pt>[];
    var k = 0;
    for (var x = -step; x < w + step; x += step, k++) {
      final px = x + pr.gauss(0, 0.12);
      final dy = switch (k % 2) {
        0 => -amp,
        _ => amp,
      };
      pts.add((px, y0 + dy + pr.gauss(0, 0.12)));
    }
    zz.write(polyD(pts));
  }
  return pathTag('$zz', stroke: tok(accent), sw: h * 0.085, op: 0.92);
}

String _gingham(Rng pr, double w, double h, String accent) {
  final q = h / 4.4;
  final hb = StringBuffer(), vb = StringBuffer();
  var i = 0;
  for (var y = 0.0; y < h + q; y += q, i++) {
    if (i.isEven) hb.write('M0 ${num10(y)}H${js(w)}V${num10(y + q)}H0Z');
  }
  i = 0;
  for (var x = pr.range(-q, 0); x < w + q; x += q, i++) {
    if (i.isEven) vb.write('M${num10(x)} 0V${js(h)}H${num10(x + q)}V0Z');
  }
  return pathTag('$hb', fill: tok(accent), op: 0.36) +
      pathTag('$vb', fill: tok(accent), op: 0.36);
}

String _kraftFibres(Rng pr, double w, double h) {
  final dark = StringBuffer(), light = StringBuffer();
  for (var i = 0; i < JsMath.roundInt((w * h) / 26); i++) {
    final x = pr.range(-4, w), y = pr.range(0, h), l = pr.range(4, 22);
    final seg =
        'M${num10(x)} ${num10(y)}l${num10(l)} ${num10(pr.range(-0.5, 0.5))}';
    final into = switch (pr() < 0.55) {
      true => dark,
      false => light,
    };
    into.write(seg);
  }
  return pathTag('$dark', stroke: tok('orange-text'), sw: 0.45, op: 0.2) +
      pathTag('$light', stroke: tok('photo'), sw: 0.5, op: 0.42);
}

String _crinkles(Rng r, double w, double h, bool clear) {
  final nc = 1 + (r.fork('crinkle')() * 2.4).floor();
  final dark = StringBuffer();
  final s = StringBuffer();
  for (var i = 0; i < nc; i++) {
    final cr = r.fork('c$i');
    final x = cr.range(0.15, 0.85) * w;
    final sl = cr.range(-0.5, 0.5) * h;
    final cw = cr.range(1.6, 4.6);
    dark.write(
      'M${num10(x - sl / 2 + cw * 0.85)} -1L${num10(x + sl / 2 + cw * 0.85)} ${js(h + 1)}',
    );
    s.write(
      pathTag(
        'M${num10(x - sl / 2)} -1L${num10(x + sl / 2)} ${js(h + 1)}',
        stroke: tok('photo'),
        sw: cw,
        op: _pick(clear, 0.5, 0.2),
        cap: 'butt',
      ),
    );
  }
  s.write(
    pathTag(
      '$dark',
      stroke: tok('ink'),
      sw: 0.7,
      op: _pick(clear, 0.05, 0.07),
      cap: 'butt',
    ),
  );
  return '$s';
}
