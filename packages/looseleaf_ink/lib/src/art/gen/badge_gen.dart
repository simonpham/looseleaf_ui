import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/text/text.dart';
import 'package:looseleaf_ink/src/core/core.dart';

double _r1(double v) => JsMath.round(v * 10) / 10;

String _f(double v) => JsMath.numberToString(_r1(v));

double _rad(double d) => (d * JsMath.pi) / 180;

double Function() _lcg(int seed) {
  var s = (seed % 2147483646) + 1;
  return () {
    s = (s * 16807) % 2147483647;
    return (s / 2147483647 - 0.5) * 2;
  };
}

String _seal(
  double cx,
  double cy,
  double r0,
  double r1,
  int n,
  double rot,
  double jit,
  double Function() rnd,
) {
  final v = <Pt>[];
  final c = <Pt>[];
  for (var i = 0; i < n; i++) {
    final a0 = _rad(rot + (i / n) * 360), a1 = _rad(rot + ((i + 1) / n) * 360);
    final am = (a0 + a1) / 2;
    final vx = cx + JsMath.cos(a0) * (r0 + rnd() * jit);
    v.add((vx, cy + JsMath.sin(a0) * (r0 + rnd() * jit)));
    final cxx = cx + JsMath.cos(am) * (r1 + rnd() * jit);
    c.add((cxx, cy + JsMath.sin(am) * (r1 + rnd() * jit)));
  }
  var d = 'M${_f(v[0].x)} ${_f(v[0].y)}';
  for (var i = 0; i < n; i++) {
    final next = v[(i + 1) % n];
    d += ' Q${_f(c[i].x)} ${_f(c[i].y)} ${_f(next.x)} ${_f(next.y)}';
  }
  return '$d Z';
}

String _burst(
  double cx,
  double cy,
  double ro,
  double ri,
  int n,
  double rot,
  double jit,
  double Function() rnd,
) {
  var d = '';
  for (var i = 0; i < n * 2; i++) {
    final a = _rad(rot + (i / (n * 2)) * 360 + rnd() * 1.5);
    final rr =
        switch (i.isOdd) {
          true => ri,
          false => ro,
        } +
        rnd() * jit;
    final lead = switch (i) {
      0 => 'M',
      _ => ' L',
    };
    d += '$lead${_f(cx + JsMath.cos(a) * rr)} ${_f(cy + JsMath.sin(a) * rr)}';
  }
  return '$d Z';
}

String _j(double v, double Function() rnd, [double a = 0.35]) =>
    _f(v + rnd() * a);

final class _Text {
  const _Text(this.x, this.y, this.w, this.em);
  final double x, y, w, em;
}

final class _Shape {
  const _Shape({
    required this.outline,
    required this.text,
    required this.deco,
    this.under,
    this.ring,
    this.sub,
    this.over,
  });

  final String outline;
  final List<ArtPart>? under;
  final String? ring;
  final _Text text;
  final ({double y, double w})? sub;
  final List<ArtPart>? over;
  final Pt deco;
}

const ArtColour _tomato = ArtColour(PaintKey.tomato);

_Shape _shapeOf(BadgeShape kind, BadgeOpts o, double Function() rnd) {
  final bumps = o.bumps ?? 12;
  final amp = o.amp ?? 3.6;
  String j(double v, [double a = 0.35]) => _j(v, rnd, a);
  switch (kind) {
    case BadgeShape.scallop:
      const r = 24.4;
      final outline = _seal(32, 32, r, r + amp, bumps, 6, 0.3, rnd);
      return _Shape(
        outline: outline,
        ring: 'O 32 32 ${j(19.6, 0.2)}',
        text: const _Text(32, 34, 30, 21),
        sub: (y: 45.4, w: 22),
        deco: (32, 21.2),
      );
    case BadgeShape.starburst:
      final n = o.bumps ?? 16;
      final outline = _burst(32, 32, 26, 21.4, n, -90, 0.4, rnd);
      return _Shape(
        outline: outline,
        ring: 'O 32 32 ${j(17.6, 0.2)}',
        text: const _Text(32, 33, 27, 20),
        sub: (y: 43.5, w: 22),
        deco: (32, 19.6),
      );
    case BadgeShape.rosette:
      final outline = _seal(32, 26.5, 17.6, 20, o.bumps ?? 16, 4, 0.2, rnd);
      return _Shape(
        outline: outline,
        under: const [
          FillPart(
            _tomato,
            'M21 40.4 L15.4 57.2 L22.4 53.4 L26.6 57.8 L30 43.4 Z',
          ),
          FillPart(
            _tomato,
            'M43 40.4 L48.6 57.2 L41.6 53.4 L37.4 57.8 L34 43.4 Z',
          ),
          StrokePart('M21 40.4 L15.4 57.2 L22.4 53.4 L26.6 57.8 L30 43.4', 0.9),
          StrokePart('M43 40.4 L48.6 57.2 L41.6 53.4 L37.4 57.8 L34 43.4', 0.9),
        ],
        ring: 'O 32 26.5 ${j(13.6, 0.2)}',
        text: const _Text(32, 28.4, 22, 16),
        sub: (y: 38.4, w: 15),
        deco: (32, 17),
      );
    case BadgeShape.plate:
      final outline =
          'M18 ${j(21)} L46 ${j(20.6)} Q${j(57.6)} 21 ${j(57.6)} 32 '
          'Q${j(57.4)} 43.4 46 43 L18 ${j(43.4)} Q6.4 43.4 ${j(6.6)} 32 '
          'Q6.4 20.6 18 ${j(21)} Z';
      final ring =
          'M15 ${j(24.4)} L49 ${j(24)} Q${j(55.6)} 24 ${j(55.6)} 32 '
          'Q${j(55.4)} 40 49 ${j(39.8)} L15 ${j(40)} Q8.4 40 8.6 32 '
          'Q8.4 24.2 15 ${j(24.4)} Z';
      return _Shape(
        outline: outline,
        ring: ring,
        text: const _Text(32, 32.6, 38, 15),
        deco: (32, 26),
      );
    case BadgeShape.shield:
      final outline =
          'M32 ${j(6.4)} L${j(54.6)} 13.6 L${j(54.4)} 34 '
          'C${j(54)} 45.6 44.4 52.6 32 ${j(57.4)} '
          'C${j(19.6)} 52.8 ${j(9.8)} 45.6 ${j(9.8)} 34 L${j(9.6)} 13.4 Z';
      final ring =
          'M32 ${j(11)} L${j(48.8)} 17 L${j(48.6)} 33.6 '
          'C48.4 42 41 47.4 32 ${j(51.8)} '
          'C${j(23)} 47.4 ${j(15.4)} 42 15.4 33.6 L${j(15.2)} 17 Z';
      return _Shape(
        outline: outline,
        ring: ring,
        text: const _Text(32, 32.4, 26, 19),
        sub: (y: 43, w: 19),
        deco: (32, 21),
      );
    case BadgeShape.ticket:
      final outline =
          'M7 ${j(16)} L57 ${j(15.6)} L57 28.4 Q52.4 32 57 35.6 '
          'L57 ${j(48)} L7 ${j(48.4)} L7 35.6 Q11.6 32 7 28.4 Z';
      final ring =
          'M12.4 ${j(20.6)} L51.6 ${j(20.4)} L51.6 ${j(43.6)} '
          'L12.4 ${j(43.8)} Z';
      return _Shape(
        outline: outline,
        ring: ring,
        text: const _Text(32, 33, 34, 16),
        sub: (y: 41.6, w: 30),
        deco: (32, 24.6),
      );
    case BadgeShape.banner:
      final outline =
          'M6.6 ${j(19)} L12 ${j(19)} L12 ${j(46.4)} L6.4 46.6 L9.6 32.6 Z '
          'M12 19 L52 ${j(18.6)} L52 ${j(46)} L12 46.4 Z '
          'M52 18.8 L57.6 ${j(19)} L54.6 32.6 L57.8 46.4 L52 46.2 Z';
      return _Shape(
        outline: outline,
        text: const _Text(32, 34, 36, 16),
        deco: (32, 25),
      );
    case BadgeShape.medal:
      final outline = _seal(32, 37.4, 18.6, 19.6, 22, 0, 0.2, rnd);
      return _Shape(
        outline: outline,
        under: const [
          FillPart(_tomato, 'M21.6 6.4 L28 6.8 L34.4 22.6 L27.6 24 Z'),
          FillPart(_tomato, 'M42.4 6.4 L36 6.8 L29.6 22.6 L36.4 24 Z'),
          StrokePart('M21.6 6.4 L28 6.8 L34.4 22.6', 0.9),
          StrokePart('M42.4 6.4 L36 6.8 L29.6 22.6', 0.9),
        ],
        ring: 'O 32 37.4 ${j(14.6, 0.2)}',
        text: const _Text(32, 41, 21, 15),
        deco: (32, 28),
      );
    case BadgeShape.tag:
      final outline =
          'M23 ${j(14.6)} L${j(41.6)} 14.4 L50 ${j(22.6)} '
          'L${j(50.4)} 57.4 L${j(13.8)} 57.6 L${j(14.2)} 22.8 Z';
      return _Shape(
        outline: outline,
        over: const [
          StrokePart('O 32 22.4 2.6', 0.8),
          StrokePart(
            'M32.4 19.8 C31.6 11.2 24 5.4 19.6 8.4 C16.4 10.8 20 16.6 25.6 12.4',
            0.85,
          ),
        ],
        text: const _Text(32, 38.6, 29, 15),
        sub: (y: 50.6, w: 24),
        deco: (32, 51.4),
      );
  }
}

String _star5(double cx, double cy, double ro, double ri) {
  var d = '';
  for (var i = 0; i < 10; i++) {
    final a = _rad(-90 + i * 36);
    final rr = switch (i.isOdd) {
      true => ri,
      false => ro,
    };
    final lead = switch (i) {
      0 => 'M',
      _ => ' L',
    };
    d += '$lead${_f(cx + JsMath.cos(a) * rr)} ${_f(cy + JsMath.sin(a) * rr)}';
  }
  return '$d Z';
}

/// A badge sticker as an art definition: an outline in [BadgeOpts.color], a
/// ring, [text] in hand lettering fitted to the shape, an optional second
/// line and decoration. The wobble is seeded by the shape, text and colour.
///
/// Mirrors `badgeSkeleton` in `src/lib/ink/art/badge-gen.ts`.
ArtDef badgeSkeleton(String text, [BadgeOpts o = const BadgeOpts()]) {
  final kind = o.shape ?? BadgeShape.scallop;
  final rnd = _lcg(hashSeed('${kind.name}:$text:${o.color?.id ?? ''}'));
  final shape = _shapeOf(kind, o, rnd);
  final color = o.fill ?? ArtColour(o.color ?? PaintKey.bubblegum);
  final ink = ArtColour(o.textColor ?? PaintKey.ink);
  final ttl = text.toUpperCase();
  final perEm = measureText(LetterFont.hand, ttl, 1);
  final em = _r1(math.min(shape.text.em, shape.text.w / perEm));
  final capH = 0.745 * em;
  List<ArtPart> build(bool small) {
    double pick(double s, double m) => switch (small) {
      true => s,
      false => m,
    };
    final parts = <ArtPart>[
      ...?shape.under,
      FillPart(color, shape.outline),
      StrokePart(shape.outline, pick(1.15, 1.05)),
    ];
    if (shape.ring case final ring?) {
      parts.addAll([
        ColourStrokePart(const ArtColour(PaintKey.photo), ring, pick(0.6, 0.5)),
        StrokePart(ring, pick(0.6, 0.5)),
      ]);
    }
    parts.addAll([...?shape.over]);
    final sub = switch ((small, o.sub, shape.sub)) {
      (false, final String line?, final ({double y, double w}) at?)
          when line.isNotEmpty =>
        (line: line, at: at),
      _ => null,
    };
    final lift = switch (sub) {
      null => 0,
      _ => 2,
    };
    final ty = shape.text.y + capH / 2 - lift;
    parts.add(
      TextPart(ttl, shape.text.x, _r1(ty), em, ink, LetterFont.hand),
    );
    if (sub != null) {
      final size = _r1(
        math.min(
          6.4,
          sub.at.w / measureText(LetterFont.hand, sub.line.toUpperCase(), 1),
        ),
      );
      parts.add(
        TextPart(
          sub.line,
          shape.text.x,
          sub.at.y + 2,
          size,
          ink,
          LetterFont.hand,
        ),
      );
    }
    final deco = o.deco;
    if (small || deco == null) return parts;
    final (x, y) = shape.deco;
    switch (deco) {
      case BadgeDeco.tick:
        parts.add(
          StrokePart(
            'M${_f(x - 3.8)} ${_f(y + 0.4)} L${_f(x - 1)} ${_f(y + 3)} '
            'L${_f(x + 4.2)} ${_f(y - 3)}',
            0.8,
          ),
        );
      case BadgeDeco.star:
        parts.addAll([
          FillPart(const ArtColour(PaintKey.lemon), _star5(x, y, 3.6, 1.6)),
          StrokePart(_star5(x, y, 3.7, 1.6), 0.6),
        ]);
      case BadgeDeco.sparkle:
        parts.add(
          StrokePart(
            'M${_f(x + 12)} ${_f(y - 4)} L${_f(x + 12.2)} ${_f(y + 2)} '
            'M${_f(x + 9)} ${_f(y - 1)} L${_f(x + 15)} ${_f(y - 1.2)}',
            0.8,
          ),
        );
      case BadgeDeco.swoosh:
        final tx = shape.text.x;
        parts.add(
          ColourStrokePart(
            _tomato,
            'M${_f(tx - em * 1.1)} ${_f(ty + 3.4)} Q${_f(tx)} ${_f(ty + 6)} '
            '${_f(tx + em * 1.2)} ${_f(ty + 2.4)}',
            0.7,
          ),
        );
      case BadgeDeco.percent:
        parts.addAll([
          ColourStrokePart(ink, 'O ${_f(x)} ${_f(y)} 3.4', 0.55),
          ColourStrokePart(
            ink,
            'M${_f(x - 2)} ${_f(y + 2)} L${_f(x + 2)} ${_f(y - 2)}',
            0.5,
          ),
        ]);
    }
    return parts;
  }

  return ArtDef(
    grid: ArtGrid.doodle,
    nibK: 0.05,
    parts: build(false),
    small: build(true),
    kind: ArtKind.sticker,
    tags: o.tags,
  );
}
