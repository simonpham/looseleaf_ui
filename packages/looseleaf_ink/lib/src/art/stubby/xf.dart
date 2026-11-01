import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// [v] rounded to one decimal.
double r1(double v) => JsMath.round(v * 10) / 10;

String _num(double v) => JsMath.numberToString(r1(v));

/// `x y`, each rounded to one decimal.
String mascotPt(double x, double y) => '${_num(x)} ${_num(y)}';

/// An ink line in the mascot's brush (`L` upstream): width `w / 1.5`, at
/// least 0.45.
///
/// Mirrors `L` in `src/lib/ink/art/mascots/body.ts`.
ArtPart mascotLine(String d, [double w = 1]) => ColourStrokePart(
  const ArtColour(PaintKey.ink),
  d,
  r1(math.max(0.45, w / 1.5)),
);

/// A blot, rounded to the grid.
///
/// Mirrors `dot` in `src/lib/ink/art/mascots/body.ts`.
ArtPart mascotDot(double x, double y, double r) => DotPart(r1(x), r1(y), r1(r));

/// Blots from `(x, y, r)` triples.
///
/// Mirrors `dots` in `src/lib/ink/art/mascots/body.ts`.
List<ArtPart> mascotDots(List<(double, double, double)> list) => [
  for (final (x, y, r) in list) mascotDot(x, y, r),
];

/// A transform of mascot parts: scale ([k], or [sx]/[sy]) and rotate [rot]
/// degrees around `(cx, cy)` (the pencil's foot by default), then move by
/// `(dx, dy)`.
///
/// Mirrors `Xf` in `src/lib/ink/art/mascots/body.ts`.
final class Xf {
  /// A transform.
  const Xf({
    this.dx,
    this.dy,
    this.rot,
    this.k,
    this.sx,
    this.sy,
    this.cx,
    this.cy,
  });

  /// Horizontal move.
  final double? dx;

  /// Vertical move.
  final double? dy;

  /// Rotation in degrees.
  final double? rot;

  /// Uniform scale.
  final double? k;

  /// Horizontal scale.
  final double? sx;

  /// Vertical scale.
  final double? sy;

  /// Pivot x.
  final double? cx;

  /// Pivot y.
  final double? cy;
}

/// The foot of the pencil, where transforms pivot by default.
///
/// Mirrors `BASE` in `src/lib/ink/art/mascots/body.ts`.
const Pt mascotBase = (32.4, 67.4);

final RegExp _xfToken = RegExp(r'[MLlQCOEZ]|-?\d*\.?\d+');
final RegExp _xfCommand = RegExp(r'^[MLlQCOEZ]$');

String _xfPath(String d, Xf t) {
  final sx = t.sx ?? t.k ?? 1, sy = t.sy ?? t.k ?? 1;
  final a = ((t.rot ?? 0) * JsMath.pi) / 180;
  final c = JsMath.cos(a), s = JsMath.sin(a);
  final cx = t.cx ?? mascotBase.x, cy = t.cy ?? mascotBase.y;
  final dx = t.dx ?? 0, dy = t.dy ?? 0;
  String at(double x, double y) {
    final ux = (x - cx) * sx, uy = (y - cy) * sy;
    return mascotPt(cx + ux * c - uy * s + dx, cy + ux * s + uy * c + dy);
  }

  String vec(double x, double y) =>
      mascotPt(x * sx * c - y * sy * s, x * sx * s + y * sy * c);
  final tok = [for (final m in _xfToken.allMatches(d)) m[0] ?? ''];
  final out = <String>[];
  var i = 0;
  while (i < tok.length) {
    final cmd = tok[i++];
    if (cmd == 'Z') {
      out.add('Z');
      continue;
    }
    final n = <double>[];
    while (i < tok.length && !_xfCommand.hasMatch(tok[i])) {
      n.add(double.tryParse(tok[i++]) ?? double.nan);
    }
    final rot = t.rot ?? 0;
    switch (cmd) {
      case 'O':
        final ry = switch (n.length > 3) {
          true => ' ${_num(n[3] * sy)}',
          false => '',
        };
        out.add('O ${at(n[0], n[1])} ${_num(n[2] * sx)}$ry');
      case 'E':
        out.add(
          'E ${at(n[0], n[1])} ${_num(n[2] * sx)} ${_num(n[3] * sy)} '
          '${_num(n[4] + rot)} ${_num(n[5] + rot)}',
        );
      default:
        final pairs = <String>[];
        for (var j = 0; j + 1 < n.length; j += 2) {
          pairs.add(switch (cmd) {
            'l' => vec(n[j], n[j + 1]),
            _ => at(n[j], n[j + 1]),
          });
        }
        out.add('$cmd ${pairs.join(' ')}');
    }
  }
  return out.join(' ');
}

/// [parts] transformed by [t], coordinates rounded to one decimal.
///
/// Mirrors `xf` in `src/lib/ink/art/mascots/body.ts`.
List<ArtPart> xf(List<ArtPart> parts, Xf t) {
  final sx = t.sx ?? t.k ?? 1, sy = t.sy ?? t.k ?? 1;
  final a = ((t.rot ?? 0) * JsMath.pi) / 180;
  final c = JsMath.cos(a), s = JsMath.sin(a);
  final cx = t.cx ?? mascotBase.x, cy = t.cy ?? mascotBase.y;
  Pt at(double x, double y) {
    final ux = (x - cx) * sx, uy = (y - cy) * sy;
    return (
      r1(cx + ux * c - uy * s + (t.dx ?? 0)),
      r1(cy + ux * s + uy * c + (t.dy ?? 0)),
    );
  }

  final scale = JsMath.sqrt(sx * sy);
  return [
    for (final p in parts)
      switch (p) {
        FillPart(:final colour, :final d, :final mis) => FillPart(
          colour,
          _xfPath(d, t),
          mis,
        ),
        StrokePart(:final d, :final width, :final hand) => StrokePart(
          _xfPath(d, t),
          width,
          hand,
        ),
        ColourStrokePart(:final colour, :final d, :final width, :final hand) =>
          ColourStrokePart(colour, _xfPath(d, t), width, hand),
        HighlightPart(:final d, :final width) => HighlightPart(
          _xfPath(d, t),
          width,
        ),
        DotPart(:final x, :final y, :final r) => DotPart(
          at(x, y).x,
          at(x, y).y,
          switch (r) {
            final double radius => r1(radius * scale),
            null => null,
          },
        ),
        TextPart(:final text, :final x, :final y, :final size) => TextPart(
          text,
          at(x, y).x,
          at(x, y).y,
          r1(size * scale),
          p.colour,
          p.font,
        ),
      },
  ];
}

/// A smooth path through [pts] (cubic, Catmull-Rom tangents), sharp at the
/// [corners] indices; [closed] wraps around and [z] adds a `Z`.
///
/// Mirrors `spline` in `src/lib/ink/art/mascots/body.ts`.
String mascotSpline(
  List<Pt> pts, {
  bool closed = false,
  List<int> corners = const [],
  bool z = false,
}) {
  final n = pts.length;
  final corner = corners.toSet();
  int wrap(int i) => ((i % n) + n) % n;
  Pt at(int i) => switch (closed) {
    true => pts[wrap(i)],
    false => pts[math.max(0, math.min(n - 1, i))],
  };
  Pt tan(int i) {
    final a = at(i - 1), b = at(i + 1);
    return ((b.x - a.x) / 6, (b.y - a.y) / 6);
  }

  final segs = switch (closed) {
    true => n,
    false => n - 1,
  };
  var d = 'M${mascotPt(pts[0].x, pts[0].y)}';
  for (var i = 0; i < segs; i++) {
    final p1 = at(i), p2 = at(i + 1);
    final c1 = switch (corner.contains(wrap(i))) {
      true => (p1.x + (p2.x - p1.x) / 3, p1.y + (p2.y - p1.y) / 3),
      false => (p1.x + tan(i).x, p1.y + tan(i).y),
    };
    final c2 = switch (corner.contains(wrap(i + 1))) {
      true => (p2.x - (p2.x - p1.x) / 3, p2.y - (p2.y - p1.y) / 3),
      false => (p2.x - tan(i + 1).x, p2.y - tan(i + 1).y),
    };
    d +=
        ' C${mascotPt(c1.x, c1.y)} ${mascotPt(c2.x, c2.y)} '
        '${mascotPt(p2.x, p2.y)}';
  }
  if (closed && z) return '$d Z';
  return d;
}

/// An ellipse as four cubics, tilted [tilt] degrees.
///
/// Mirrors `oval` in `src/lib/ink/art/mascots/body.ts`.
String mascotOval(
  double cx,
  double cy,
  double rx,
  double ry, [
  double tilt = 0,
]) {
  const k = 0.5523;
  final a = (tilt * JsMath.pi) / 180;
  final c = JsMath.cos(a), s = JsMath.sin(a);
  String q(double x, double y) =>
      mascotPt(cx + x * c - y * s, cy + x * s + y * c);
  return 'M${q(rx, 0)} C${q(rx, ry * k)} ${q(rx * k, ry)} ${q(0, ry)} '
      'C${q(-rx * k, ry)} ${q(-rx, ry * k)} ${q(-rx, 0)} '
      'C${q(-rx, -ry * k)} ${q(-rx * k, -ry)} ${q(0, -ry)} '
      'C${q(rx * k, -ry)} ${q(rx, -ry * k)} ${q(rx, 0)} Z';
}
