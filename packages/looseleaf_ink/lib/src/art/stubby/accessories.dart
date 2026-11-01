import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/stubby/pose.dart';
import 'package:looseleaf_ink/src/art/stubby/xf.dart';
import 'package:looseleaf_ink/src/core/core.dart';

String _f1(double v) => JsMath.numberToString(JsMath.round(v * 10) / 10);

ArtPart _c(PaintKey key, String d, [double? w]) =>
    ColourStrokePart(ArtColour(key), d, w);

ArtPart _fill(PaintKey key, String d) => FillPart(ArtColour(key), d);

double _rad(double deg) => (deg * JsMath.pi) / 180;

/// A thought cloud of [bumps] arcs around `(cx, cy)`.
///
/// Mirrors `cloudPath` in `src/lib/ink/art/mascots/props.ts`.
String cloudPath(
  double cx,
  double cy,
  double rx,
  double ry,
  int bumps, [
  double a0 = 140,
  double open = 0.03,
]) {
  final out = <String>[];
  final span = 360 * (1 - open);
  Pt pt(double deg, double k) => (
    cx + JsMath.cos(_rad(deg)) * rx * k,
    cy + JsMath.sin(_rad(deg)) * ry * k,
  );
  final p0 = pt(a0, 1);
  out.add('M ${_f1(p0.x)} ${_f1(p0.y)}');
  for (var i = 1; i <= bumps; i++) {
    final a = a0 + (span * i) / bumps;
    final m = a0 + (span * (i - 0.5)) / bumps;
    final wob = 1 + 0.06 * JsMath.sin(i * 2.3);
    final c = pt(m, 1.42 * wob);
    final e = pt(a, 1 + 0.03 * JsMath.cos(i * 1.7));
    out.add('Q ${_f1(c.x)} ${_f1(c.y)} ${_f1(e.x)} ${_f1(e.y)}');
  }
  return out.join(' ');
}

/// A pencil scribble of [loops] loops from `(x0, y0)`, [frac] of it drawn.
///
/// Mirrors `loopsPath` in `src/lib/ink/art/mascots/props.ts`.
String loopsPath(
  double x0,
  double y0,
  double w,
  double amp,
  int loops,
  double rise, [
  double? hx,
  double frac = 1,
]) {
  final hxv = hx ?? amp * 0.36;
  final n = math.max(6, JsMath.roundInt(loops * 18 * frac));
  final pts = <String>[];
  for (var i = 0; i <= n; i++) {
    final t = (i / n) * frac;
    final a = t * loops * JsMath.pi * 2;
    final loop = ((a - 0.001) / (JsMath.pi * 2)).floor();
    final grow = (0.5 + 0.5 * t) * (1 + 0.22 * JsMath.sin(loop * 2.1 + 0.6));
    final x =
        x0 +
        t * w +
        JsMath.sin(a) * hxv * grow * (1 + 0.18 * JsMath.sin(3.1 * a));
    final y =
        y0 -
        t * rise -
        JsMath.cos(a) * amp * grow * (1 + 0.12 * JsMath.sin(2.3 * a)) +
        amp * grow;
    final lead = switch (i) {
      0 => 'M',
      _ => 'L',
    };
    pts.add('$lead ${_f1(x)} ${_f1(y)}');
  }
  return pts.join(' ');
}

String _dashRun(
  double x0,
  double y0,
  double x1,
  double y1,
  List<double> lens,
  double gap,
) {
  final len = JsMath.hypot(x1 - x0, y1 - y0);
  final ux = (x1 - x0) / len, uy = (y1 - y0) / len;
  final out = <String>[];
  var s = 0.4;
  for (var i = 0; s < len - 1; i++) {
    final d = math.min(lens[i % lens.length], len - s);
    out.add(
      'M ${_f1(x0 + ux * s)} ${_f1(y0 + uy * s + JsMath.sin(i * 2.1) * 0.18)} '
      'L ${_f1(x0 + ux * (s + d))} ${_f1(y0 + uy * (s + d) + JsMath.cos(i * 1.7) * 0.18)}',
    );
    s += d + gap + (i % 3) * 0.35;
  }
  return out.join(' ');
}

String _octagon(double cx, double cy, double r, [double rot = 22.5]) {
  final out = <String>[];
  for (var i = 0; i < 8; i++) {
    final a = _rad(rot + i * 45);
    final wob = 1 + 0.03 * JsMath.sin(i * 2.9);
    final lead = switch (i) {
      0 => 'M',
      _ => 'L',
    };
    out.add(
      '$lead ${_f1(cx + JsMath.cos(a) * r * wob)} ${_f1(cy + JsMath.sin(a) * r * wob)}',
    );
  }
  return '${out.join(' ')} Z';
}

/// A hand-drawn question mark at `(x, y)`.
///
/// Mirrors `questionMark` in `src/lib/ink/art/mascots/props.ts`.
List<ArtPart> questionMark(
  double x,
  double y, [
  double k = 1,
  double rot = 0,
  PaintKey colour = PaintKey.ink,
]) {
  const hook =
      'M0 5.4 Q0.2 0.6 4.6 0.4 Q9.6 0.6 9.2 5.4 Q8.8 8.4 5.6 10 Q4.2 11 4.4 13.4';
  final t = Xf(cx: 4.6, cy: 8, k: k, rot: rot, dx: x - 4.6, dy: y - 8);
  final w = switch (colour) {
    PaintKey.ink => 0.8,
    _ => 0.95,
  };
  return xf([_c(colour, '$hook M3.9 17.2 L5.9 17.9', w)], t);
}

/// A thought cloud over the head.
///
/// Mirrors `thoughtCloud` in `src/lib/ink/art/mascots/props.ts`.
final Acc thoughtCloud = Acc(
  m: [
    _fill(PaintKey.photo, cloudPath(49.8, 11.6, 8.2, 5.2, 5)),
    _c(
      PaintKey.pencil,
      '${cloudPath(49.8, 11.6, 8.2, 5.2, 5)} O 43.4 21.8 1.8 1.5',
      0.45,
    ),
    mascotLine(
      'M45.8 12 L46.5 12.1 M49.6 12.2 L50.3 12.3 M53.6 11.8 L54.3 11.9',
      1.1,
    ),
  ],
  s: [
    _fill(PaintKey.photo, cloudPath(49.8, 11.6, 8.4, 5.4, 5)),
    _c(
      PaintKey.pencil,
      '${cloudPath(49.8, 11.6, 8.4, 5.4, 5)} O 43.4 21.8 2 1.7',
      0.8,
    ),
    mascotLine(
      'M45.8 12 L46.6 12.1 M49.6 12.2 L50.4 12.3 M53.6 11.8 L54.4 11.9',
      1.3,
    ),
  ],
  u: [
    _c(
      PaintKey.pencil,
      'M41.6 24.6 L43 24.7 M46 17.4 L47.6 17.5 M52.2 9.6 L54.2 9.7',
      1.7,
    ),
  ],
);

const List<String> _swish = [
  'M50.2 21.8 Q55 27.4 50.2 33.6 M56 16.6 Q61 27 56.2 37.6',
  'M49 21.2 Q53.8 26.8 49 33 M54.6 15.8 Q59.8 26.4 54.8 37',
  'M51.4 22.6 Q56.2 28 51.4 34.4 M57 17.8 Q61 27.4 57.2 38.4',
];

/// Motion marks of a waving hand, animation [frame] 0 to 2.
///
/// Mirrors `waveMarks` in `src/lib/ink/art/mascots/props.ts`.
Acc waveMarks(int frame) => Acc(
  m: [_c(PaintKey.sky, _swish[frame], 0.75)],
  s: [_c(PaintKey.sky, _swish[frame], 1)],
  u: [_c(PaintKey.sky, _swish[frame].split(' M')[0], 1.6)],
);

/// Sleeping Zs.
///
/// Mirrors `zzz` in `src/lib/ink/art/mascots/props.ts`.
final Acc zzz = Acc(
  m: [
    _c(
      PaintKey.inkYou,
      'M47.6 27.2 L52.4 27.2 L47.6 32.2 L52.4 32.2 M50.6 15.6 L56.6 15.6 '
      'L50.6 22.4 L56.6 22.4',
      0.5,
    ),
    _c(PaintKey.inkYou, 'M52.4 3.6 L60 3.6 L52.4 12.6 L60 12.6', 0.58),
  ],
  s: [
    _c(PaintKey.inkYou, 'M50.4 15.4 L56.8 15.4 L50.4 22.6 L56.8 22.6', 0.75),
    _c(PaintKey.inkYou, 'M52.2 3.4 L60.2 3.4 L52.2 12.8 L60.2 12.8', 0.82),
  ],
  u: [_c(PaintKey.inkYou, 'M49.4 13.2 L56.6 13.2 L49.4 22 L56.6 22', 1.1)],
);

const String _drop =
    'M10.8 20.4 Q6 27.2 7.2 30.8 Q9.2 34.2 12.8 31.8 Q14.6 28.2 10.8 20.4 Z';

/// A drop of sweat and shock marks.
///
/// Mirrors `sweatDrop` in `src/lib/ink/art/mascots/props.ts`.
final Acc sweatDrop = Acc(
  m: [
    _fill(PaintKey.sky, _drop),
    mascotLine(
      '$_drop M33.8 6.2 L31.8 3.6 M39.2 4.4 L39.8 3.2 M44.6 7.2 L47.6 5.8',
      0.75,
    ),
  ],
  s: [
    _fill(PaintKey.sky, _drop),
    mascotLine('$_drop M33.8 6.2 L31.6 3.6 M44.6 7.2 L47.8 5.8', 0.95),
  ],
  u: [_c(PaintKey.sky, 'M10.4 21 Q6.4 27 8.8 30.8', 1.7)],
);

/// Falling confetti, animation [frame] 0 or 1.
///
/// Mirrors `confetti` in `src/lib/ink/art/mascots/props.ts`.
Acc confetti(int frame) {
  final fall = Xf(dy: frame * 2.4);
  return Acc(
    m: xf([
      _c(
        PaintKey.tomato,
        'M7.2 18.2 L11 16.6 M6 27.4 L9.4 25.6 M16.6 6.4 L18.8 9.6 '
        'M55 16.8 L55.2 23 M51.8 20 L58.4 19.8',
        1.1,
      ),
      _c(
        PaintKey.sky,
        'M52.4 12.2 L56.2 13.8 M10 4.6 L10.2 10.8 M6.8 7.8 L13.4 7.6 '
        'M47.4 5.6 L49.6 8.6 M44 8.2 L41.8 11.4',
        1.1,
      ),
    ], fall),
    s: xf([
      _c(
        PaintKey.tomato,
        'M7.2 18.2 L11 16.6 M16.6 6.4 L18.8 9.6 M55 16.8 L55.2 23 '
        'M51.8 20 L58.4 19.8',
        1.3,
      ),
      _c(
        PaintKey.sky,
        'M52.4 12.2 L56.2 13.8 M10 4.6 L10.2 10.8 M6.8 7.8 L13.4 7.6',
        1.3,
      ),
    ], fall),
    u: xf([
      _c(PaintKey.tomato, 'M6.2 9.2 L12.2 8.8 M53 10 L56.6 11.2', 1.6),
    ], fall),
  );
}

/// Extra confetti at large sizes.
///
/// Mirrors `confettiHi` in `src/lib/ink/art/mascots/props.ts`.
final List<ArtPart> confettiHi = [
  _c(
    PaintKey.lemon,
    'M13 15 L13.2 20.4 M10.4 17.6 L16 17.4 M50.6 27.4 L50.8 32.6 '
    'M48 30 L53.4 29.8',
    0.8,
  ),
  _c(PaintKey.grass, 'M9 32 L12.4 30.4 M56.6 6 L58.2 9', 0.95),
];

List<ArtPart> _heavier(List<ArtPart> parts, double k) => [
  for (final p in parts)
    switch (p) {
      ColourStrokePart(:final colour, :final d, :final width) =>
        ColourStrokePart(colour, d, (width ?? 1) * k),
      _ => p,
    },
];

/// Two question marks.
///
/// Mirrors `questions` in `src/lib/ink/art/mascots/props.ts`.
final Acc questions = Acc(
  m: [
    ...questionMark(50.4, 14.4, 1.12, 9),
    ...questionMark(9.2, 22, 0.82, -12),
  ],
  s: [
    ..._heavier(questionMark(50.4, 14.4, 1.16, 9), 1.35),
    ...questionMark(9.2, 22, 0.88, -12),
  ],
  u: _heavier(questionMark(50.4, 14.4, 1.2, 9), 1.6),
);

const String _handle = 'M50.6 50.2 L53.4 48 L59.4 55.8 L56.4 58.4 Z';

/// A magnifying glass.
///
/// Mirrors `magnifier` in `src/lib/ink/art/mascots/props.ts`.
final Acc magnifier = Acc(
  m: [
    _fill(PaintKey.tangerine, _handle),
    mascotLine('O 44.6 43.4 9 $_handle', 1),
    mascotLine('O 42.4 42.4 4.6', 0.8),
    mascotDot(43, 42.6, 2.2),
  ],
  s: [
    _fill(PaintKey.tangerine, _handle),
    mascotLine('O 44.6 43.4 9 $_handle', 1.3),
    mascotDot(42.8, 42.6, 2.9),
  ],
  u: [_fill(PaintKey.tangerine, _handle), mascotLine('O 44.6 43.4 9', 1.6)],
);

/// A stop sign.
///
/// Mirrors `stopSign` in `src/lib/ink/art/mascots/props.ts`.
final Acc stopSign = Acc(
  m: [
    _fill(PaintKey.tomato, _octagon(51.4, 12.8, 8.2)),
    mascotLine(_octagon(51.4, 12.8, 8.2), 0.8),
    _c(PaintKey.photo, 'M46.4 13 L56.4 12.6', 1.2),
  ],
  s: [
    _fill(PaintKey.tomato, _octagon(51.4, 12.8, 8.2)),
    mascotLine(_octagon(51.4, 12.8, 8.2), 1),
    _c(PaintKey.photo, 'M46.2 13 L56.6 12.6', 1.5),
  ],
  u: [
    _fill(PaintKey.tomato, _octagon(51.4, 12.8, 8)),
    mascotLine(_octagon(51.4, 12.8, 8), 1.2),
  ],
);

const String _plug = 'M53.2 60.2 L59.8 60 L60 66.8 L53.4 67 Z';
const String _cable =
    'M50.6 47.8 Q57.4 48.4 57 54.6 Q56.6 57.8 56.6 60.2 $_plug '
    'M53 62 L50 62 M53.2 65.2 L50.2 65.2';

/// An unplugged cable with sparks.
///
/// Mirrors `cableCut` in `src/lib/ink/art/mascots/props.ts`.
final Acc cableCut = Acc(
  m: [
    _fill(PaintKey.tangerine, _plug),
    mascotLine(_cable, 0.85),
    _c(
      PaintKey.tangerine,
      'M52.6 43.6 L54.8 40.4 M55.8 46.6 L59.6 45.2 M50.6 42.6 L51 39.4',
      0.85,
    ),
  ],
  s: [
    _fill(PaintKey.tangerine, _plug),
    mascotLine(_cable, 1),
    _c(PaintKey.tangerine, 'M52.6 43.6 L54.8 40.4 M55.8 46.6 L59.6 45.2', 1.1),
  ],
  u: [_c(PaintKey.tangerine, 'M52.6 45 L55 41.6 M55.8 48 L59.8 46.6', 1.6)],
);

const String _box = 'M44.8 48.8 L59.6 47.2 L60 65.2 L45.2 66.8 Z';
const String _boxLines =
    'M44.6 49 L59.8 47 L60.2 65.4 L45 67 Z M52.4 48 L52.8 66 M45 57.4 L60 56';

/// A parcel.
///
/// Mirrors `parcel` in `src/lib/ink/art/mascots/props.ts`.
final Acc parcel = Acc(
  m: [_fill(PaintKey.kraft, _box), mascotLine(_boxLines, 0.8)],
  s: [_fill(PaintKey.kraft, _box), mascotLine(_boxLines, 1)],
  u: [
    _fill(PaintKey.kraft, _box),
    mascotLine('M44.6 49 L59.8 47 L60.2 65.4 L45 67 Z', 1.2),
  ],
);

const String _arrow =
    'M46.6 31 Q53 29.4 58.6 31.8 M53.6 26 L59.2 31.8 L53.4 36.6';

/// A pointing arrow.
///
/// Mirrors `arrow` in `src/lib/ink/art/mascots/props.ts`.
final Acc pointArrow = Acc(
  m: [_c(PaintKey.tangerine, _arrow, 0.7)],
  s: [_c(PaintKey.tangerine, _arrow, 1)],
  u: [_c(PaintKey.tangerine, _arrow, 1.7)],
);

String _dashedBox(List<double> lens) => [
  _dashRun(46.4, 5.2, 60.2, 5.6, lens, 1.7),
  _dashRun(60.2, 5.6, 60, 21.4, lens, 1.7),
  _dashRun(60, 21.4, 46.2, 21, lens, 1.7),
  _dashRun(46.2, 21, 46.4, 5.2, lens, 1.7),
].join(' ');

/// A dashed placeholder frame.
///
/// Mirrors `dashedFrame` in `src/lib/ink/art/mascots/props.ts`.
final Acc dashedFrame = Acc(
  m: [
    mascotLine(_dashedBox([3.6, 2.6]), 0.62),
  ],
  s: [
    mascotLine(_dashedBox([4.2, 3]), 0.9),
  ],
  u: [
    mascotLine(
      'M47.2 6.2 L52.2 5.8 M55.2 6.1 L60.4 6.3 L60.2 11.4 M60.2 14.6 '
      'L60 20.2 M55.4 21.3 L47.3 20.8',
      1.2,
    ),
  ],
);

/// A scribble drawn from `(x, y)`, [frac] of it done.
///
/// Mirrors `scribble` in `src/lib/ink/art/mascots/props.ts`.
Acc scribbleAcc(double x, double y, [double frac = 1]) => Acc(
  m: [_c(PaintKey.pencil, loopsPath(x, y, 59 - x, 5.2, 4, -6, 2, frac), 0.5)],
  s: [_c(PaintKey.pencil, loopsPath(x, y, 59 - x, 5.2, 3, -6, 2.1, frac), 0.8)],
  u: [_c(PaintKey.pencil, loopsPath(x, y, 59 - x, 5.4, 2, -6, 2.1, frac), 1.5)],
);
