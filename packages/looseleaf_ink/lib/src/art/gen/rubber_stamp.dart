import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/text/text.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

List<Pt> _flip(List<Pt> pts) => switch (area(pts) > 0) {
  true => pts.reversed.toList(),
  false => pts,
};

String _ring(List<Pt> outer, List<Pt> inner) {
  final o = switch (area(outer) < 0) {
    true => outer.reversed.toList(),
    false => outer,
  };
  return polyPath(o, 10) + polyPath(_flip(inner), 10);
}

List<Pt> _star(double cx, double cy, double ro, double ri, [double rot = -90]) {
  return [
    for (var i = 0; i < 10; i++)
      (
        cx +
            JsMath.cos(((rot + i * 36) * JsMath.pi) / 180) *
                switch (i.isOdd) {
                  true => ri,
                  false => ro,
                },
        cy +
            JsMath.sin(((rot + i * 36) * JsMath.pi) / 180) *
                switch (i.isOdd) {
                  true => ri,
                  false => ro,
                },
      ),
  ];
}

String _dashes(List<Pt> poly, double len, double gap, double w, Rng rng) {
  var d = '';
  final m = poly.length;
  var on = true;
  var left = len;
  for (var i = 0; i < m; i++) {
    final a = poly[i], b = poly[(i + 1) % m];
    final segment = JsMath.hypot(b.x - a.x, b.y - a.y);
    final ux = (b.x - a.x) / JsMath.or(segment, 1);
    final uy = (b.y - a.y) / JsMath.or(segment, 1);
    var s = 0.0;
    while (s < segment) {
      final step = math.min(left, segment - s);
      if (on && step > 0.5) {
        final p0 = (a.x + ux * s, a.y + uy * s);
        final p1 = (a.x + ux * (s + step), a.y + uy * (s + step));
        final nx = -uy * w * 0.5, ny = ux * w * 0.5;
        d += polyPath([
          (p0.x + nx, p0.y + ny),
          (p1.x + nx, p1.y + ny),
          (p1.x - nx, p1.y - ny),
          (p0.x - nx, p0.y - ny),
        ], 10);
      }
      s += step;
      left -= step;
      if (left <= 0.01) {
        on = !on;
        final base = switch (on) {
          true => len,
          false => gap,
        };
        left = base * (0.85 + rng() * 0.3);
      }
    }
  }
  return d;
}

List<Pt> _cleanRect(double x, double y, double w, double h, double r) =>
    densifyClosed(roundRectPoly(x, y, w, h, r, 5), 5);

List<Pt> _circle(double cx, double cy, double r, int count, double step) =>
    densifyClosed(ellipsePoly(cx, cy, r, r, count), step);

String _burstRings(double cx, double cy, double rr0) {
  final pts = <Pt>[];
  for (var i = 0; i < 24; i++) {
    final a = (i / 24) * JsMath.pi * 2 - JsMath.pi / 2;
    final rr = switch (i.isOdd) {
      true => rr0 * 0.82,
      false => rr0 - 1,
    };
    pts.add((cx + JsMath.cos(a) * rr, cy + JsMath.sin(a) * rr));
  }
  return _ring(pts, _circle(cx, cy, rr0 * 0.76, 48, 4)) +
      _ring(
        _circle(cx, cy, rr0 * 0.66, 48, 4),
        _circle(cx, cy, rr0 * 0.66 - 1.1, 48, 4),
      );
}

String _roundRings(double cx, double cy, double rr0) {
  final rin = rr0 * 0.63;
  return _ring(
        _circle(cx, cy, rr0 - 0.5, 60, 5),
        _circle(cx, cy, rr0 - 0.5 - 2.6, 60, 5),
      ) +
      _ring(_circle(cx, cy, rin, 48, 4), _circle(cx, cy, rin - 1.1, 48, 4));
}

String _seedText(Object seed) => switch (seed) {
  final num v => JsMath.numberToString(v),
  _ => '$seed',
};

/// A rubber stamp impression of [text]: a framed rectangle, a round seal
/// with rim lettering, a starburst, or a slanted VOID, in typewriter
/// lettering, tilted, with an optional faint ghost impression.
///
/// Mirrors `stamp` in `src/lib/ink/art/rubber-stamp.ts`.
InkResult stamp(
  String text,
  StampShape shape, [
  StampOpts o = const StampOpts(),
]) {
  final key = (o.ink ?? StampPadInk.red).paint;
  final seed = 'stamp:${_seedText(o.seed ?? text)}:${shape.id}';
  final ink = Ink(seed, tier: Tier.lo, grain: o.grain);
  final rng = ink.rng.fork('stamp');
  final round = shape == StampShape.round || shape == StampShape.burst;
  final w =
      o.w ??
      switch (round) {
        true => 96.0,
        false => 160.0,
      };
  final h =
      o.h ??
      switch ((round, shape)) {
        (true, _) => w,
        (_, StampShape.voided) => 64,
        _ => 56,
      };
  final tilt = o.tilt ?? rng.range(-5, 5);
  final cx = w / 2, cy = h / 2;
  final upper = text.toUpperCase();

  void impression(Rng r, double alpha) {
    var d = '';
    switch (shape) {
      case StampShape.rect:
        final outerW = clamp(h * 0.045, 2, 3);
        const innerW = 1.1;
        final a = _cleanRect(0, 0, w, h, 5);
        final b = _cleanRect(
          outerW,
          outerW,
          w - 2 * outerW,
          h - 2 * outerW,
          3.4,
        );
        d += _ring(a, b);
        const gap = 3.1;
        final c = _cleanRect(
          outerW + gap,
          outerW + gap,
          w - 2 * (outerW + gap),
          h - 2 * (outerW + gap),
          2.4,
        );
        final e = _cleanRect(
          outerW + gap + innerW,
          outerW + gap + innerW,
          w - 2 * (outerW + gap + innerW),
          h - 2 * (outerW + gap + innerW),
          2,
        );
        d += switch (o.dashed ?? false) {
          true => _dashes(c, 5.5, 3.2, innerW + 0.3, r.fork('dash')),
          false => _ring(c, e),
        };
        final innerH = h - 2 * (outerW + gap + innerW);
        final innerW2 = w - 2 * (outerW + gap + innerW) - 10;
        final sub = switch (o.sub) {
          final String s when s.isNotEmpty => s,
          _ => null,
        };
        var em = math.min(
          innerH *
              switch (sub) {
                null => 0.62,
                _ => 0.5,
              },
          38.0,
        );
        final spacing = clamp(em * 0.08, 1, 3.4);
        final fit =
            innerW2 /
            math.max(
              1.0,
              measureText(LetterFont.type, upper, 1, 0) +
                  (upper.length - 1) * (spacing / em),
            );
        em = math.min(em, fit);
        final cap = 0.68 * em;
        final ty = switch (sub) {
          null => cy + cap / 2,
          _ => cy - innerH * 0.06 + cap / 2 - 1,
        };
        d += textPath(
          upper,
          cx,
          ty,
          em,
          r.fork('t'),
          TextOpts(
            font: LetterFont.type,
            spacing: (spacing * em) / math.max(em, 1) * 0.9,
            jitter: 0.25,
          ),
        ).d;
        if (sub != null) {
          final sm = clamp(innerH * 0.2, 6, 10);
          d += textPath(
            sub.toUpperCase(),
            cx,
            cy + innerH * 0.34,
            sm,
            r.fork('s'),
            const TextOpts(font: LetterFont.type, spacing: 1.2, jitter: 0.2),
          ).d;
        }
      case StampShape.round || StampShape.burst:
        final rr0 = w / 2;
        d += switch (shape) {
          StampShape.burst => _burstRings(cx, cy, rr0),
          _ => _roundRings(cx, cy, rr0),
        };
        final inner = switch (shape) {
          StampShape.burst => rr0 * 0.6,
          _ => rr0 * 0.62,
        };
        var em = math.min(w * 0.3, 40.0);
        final fit =
            (inner * 1.78) /
            math.max(
              0.5,
              measureText(LetterFont.type, upper, 1, 0) + upper.length * 0.06,
            );
        em = math.min(em, fit);
        final cap = 0.68 * em;
        final sub = switch (o.sub) {
          final String s when s.isNotEmpty => s,
          _ => null,
        };
        final lift = switch (sub) {
          null => 0.0,
          _ => 1.5,
        };
        d += textPath(
          upper,
          cx,
          cy + cap / 2 - lift,
          em,
          r.fork('t'),
          TextOpts(font: LetterFont.type, spacing: em * 0.06, jitter: 0.25),
        ).d;
        if (sub != null) {
          d += textPath(
            sub.toUpperCase(),
            cx,
            cy + cap / 2 + em * 0.42,
            math.max(5.5, em * 0.28),
            r.fork('s'),
            const TextOpts(font: LetterFont.type, spacing: 0.8, jitter: 0.2),
          ).d;
        }
        final ns =
            o.stars ??
            switch (shape) {
              StampShape.round => 2,
              _ => 0,
            };
        for (var i = 0; i < ns; i++) {
          final side = switch (i) {
            0 => -1,
            _ => 1,
          };
          final sx = cx + side * inner * 0.68;
          d += polyPath(_star(sx, cy - cap * 1.05 - 3, 2.6, 1.1, -90), 10);
        }
        if (shape == StampShape.round) d += _rim(o.ring ?? '', cx, cy, rr0, r);
      case StampShape.voided:
        final em = math.min(
          h * 0.86,
          (w * 0.86) / math.max(1.0, measureText(LetterFont.type, upper, 1, 0)),
        );
        d += textPath(
          upper,
          cx,
          cy + em * 0.34,
          em,
          r.fork('t'),
          TextOpts(
            font: LetterFont.type,
            spacing: em * 0.04,
            jitter: 0.35,
            rot: -8,
          ),
        ).d;
        final bar = densifyClosed([
          (cx - w * 0.44, cy + 3.5),
          (cx + w * 0.44, cy - 3.2),
          (cx + w * 0.44, cy - 0.2),
          (cx - w * 0.44, cy + 6.4),
        ], 5);
        d += polyPath(_flip(bar), 10);
    }
    ink.flat(
      Material.text,
      d,
      key,
      op: alpha,
      bbox: BBox(-6, -6, w + 6, h + 6),
    );
  }

  final turn =
      'rotate(${JsMath.toFixed(tilt, 2)} ${JsMath.toFixed(cx, 1)} ${JsMath.toFixed(cy, 1)})';
  ink.group(GroupAttrs(transform: turn), () {
    if (o.ghost ?? false) {
      final shift =
          'translate(1.6 -1.3) rotate(0.8 ${JsMath.toFixed(cx, 1)} ${JsMath.toFixed(cy, 1)})';
      ink.group(
        GroupAttrs(transform: shift),
        () => impression(rng.fork('ghost'), 0.2),
        Material.stamp,
      );
    }
    impression(rng.fork('main'), 0.92);
  }, Material.stamp);
  return ink.toSvg(w: w, h: h, pad: 10);
}

String _rim(String rim, double cx, double cy, double rr0, Rng r) {
  final chars = rim.toUpperCase().runes.map(String.fromCharCode).toList();
  if (chars.isEmpty) return '';
  var d = '';
  final rr = rr0 - 2.6 - 3.4 - 2;
  final span = switch (chars.length >= 12) {
    true => 300.0,
    false => chars.length * 26.0,
  };
  final sz = clamp(
    (rr * ((span * JsMath.pi) / 180)) / (chars.length * 0.86),
    5.2,
    10,
  );
  for (var i = 0; i < chars.length; i++) {
    final ch = chars[i];
    if (ch == ' ') continue;
    final ang = -90 - span / 2 + ((i + 0.5) / chars.length) * span;
    final a = (ang * JsMath.pi) / 180;
    d += textPath(
      ch,
      cx + JsMath.cos(a) * rr,
      cy + JsMath.sin(a) * rr,
      sz,
      r.fork('ch$i'),
      TextOpts(font: LetterFont.type, rot: ang + 90, jitter: 0.1),
    ).d;
  }
  return d;
}
