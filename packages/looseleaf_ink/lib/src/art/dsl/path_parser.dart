import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

final RegExp _token = RegExp(r'[MLlQCOEZ]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?');
final RegExp _command = RegExp(r'^[MLlQCOEZ]$');
final RegExp _separators = RegExp(r'[\s,]+');

/// The tokens of an art path and whatever is left that is not one.
///
/// Mirrors `tokenize` in `src/lib/ink/art/dsl.ts`.
({List<String> tok, String bad}) tokenize(String d) => (
  tok: [for (final m in _token.allMatches(d)) m[0] ?? ''],
  bad: d.replaceAll(_token, '').replaceAll(_separators, ''),
);

/// Whether [token] is a command letter.
bool isArtCommand(String token) => _command.hasMatch(token);

/// One sub-path of a parsed art path: its points, which of them are corners
/// ([anchor]), whether it closes, and how many points make the [shape]
/// (the rest is the pen's overshoot past the start).
///
/// Mirrors `Sub` in `src/lib/ink/art/dsl.ts`.
final class Sub {
  /// The points.
  final List<Pt> pts = [];

  /// Whether each point is a corner.
  final List<bool> anchor = [];

  /// Whether the sub-path is closed.
  bool closed = false;

  /// The points that make the outline, without the overshoot.
  int shape = 0;
}

/// Parses the art DSL into polylines: `M x y …`, `L x y …`, `l dx dy …`,
/// `Q x1 y1 x y …`, `C x1 y1 x2 y2 x y …`, `O cx cy rx [ry]` (a hand-drawn
/// oval), `E cx cy rx ry a0 a1` (an arc in degrees) and `Z` (close with an
/// overshoot). Curves are sampled every [step]; [rnd] varies ovals and
/// overshoots (0.5 by default).
///
/// Mirrors `parsePath` in `src/lib/ink/art/dsl.ts`.
List<Sub> parsePath(String d, {double step = 0.6, double Function()? rnd}) {
  final random = rnd ?? () => 0.5;
  final tok = tokenize(d).tok;
  final subs = <Sub>[];
  Sub? cur;
  var cx = 0.0, cy = 0.0, sx = 0.0, sy = 0.0, i = 0;
  double num() {
    if (i >= tok.length) {
      i++;
      return double.nan;
    }
    return double.tryParse(tok[i++]) ?? double.nan;
  }

  bool isNum() => i < tok.length && !_command.hasMatch(tok[i]);
  void push(double x, double y, bool anchor) {
    final sub = cur ?? Sub();
    if (cur == null) {
      subs.add(sub);
      cur = sub;
    }
    sub.pts.add((x, y));
    sub.anchor.add(anchor);
    cx = x;
    cy = y;
  }

  while (i < tok.length) {
    final c = tok[i++];
    switch (c) {
      case 'M':
        cur = null;
        sx = num();
        sy = num();
        push(sx, sy, true);
        while (isNum()) {
          push(num(), num(), true);
        }
      case 'L':
        while (isNum()) {
          push(num(), num(), true);
        }
      case 'l':
        while (isNum()) {
          final x = cx + num();
          push(x, cy + num(), true);
        }
      case 'Q':
        while (isNum()) {
          final x1 = num(), y1 = num(), x2 = num(), y2 = num();
          final x0 = cx, y0 = cy;
          final n = math.max(
            3,
            (JsMath.hypot(x2 - x0, y2 - y0) / step).ceil(),
          );
          for (var k = 1; k <= n; k++) {
            final t = k / n, u = 1 - t;
            push(
              u * u * x0 + 2 * u * t * x1 + t * t * x2,
              u * u * y0 + 2 * u * t * y1 + t * t * y2,
              k == n,
            );
          }
        }
      case 'C':
        while (isNum()) {
          final x1 = num(), y1 = num(), x2 = num(), y2 = num();
          final x3 = num(), y3 = num();
          final x0 = cx, y0 = cy;
          final n = math.max(
            4,
            ((JsMath.hypot(x1 - x0, y1 - y0) +
                        JsMath.hypot(x2 - x1, y2 - y1) +
                        JsMath.hypot(x3 - x2, y3 - y2)) /
                    step)
                .ceil(),
          );
          for (var k = 1; k <= n; k++) {
            final t = k / n, u = 1 - t;
            push(
              u * u * u * x0 +
                  3 * u * u * t * x1 +
                  3 * u * t * t * x2 +
                  t * t * t * x3,
              u * u * u * y0 +
                  3 * u * u * t * y1 +
                  3 * u * t * t * y2 +
                  t * t * t * y3,
              k == n,
            );
          }
        }
      case 'O':
        final ox = num(), oy = num(), rx = num();
        final ry = switch (isNum()) {
          true => num(),
          false => rx,
        };
        cur = null;
        final n = math.max(20, (((rx + ry) * JsMath.pi * 1.1) / step).ceil());
        final a0 = -2.3 + (random() - 0.5) * 0.7;
        for (var k = 0; k <= n; k++) {
          final a = a0 + (k / n) * tau * 1.09;
          final kk = 1 + 0.02 * JsMath.sin(2 * a);
          push(
            ox + JsMath.cos(a) * rx * kk,
            oy + JsMath.sin(a) * ry * kk,
            false,
          );
        }
        final oval = cur;
        if (oval != null) {
          oval
            ..closed = true
            ..shape = JsMath.roundInt(n / 1.09);
        }
        sx = oval?.pts[0].x ?? ox;
        sy = oval?.pts[0].y ?? oy;
      case 'E':
        final ox = num(), oy = num(), rx = num(), ry = num();
        final a0 = (num() * JsMath.pi) / 180, a1 = (num() * JsMath.pi) / 180;
        final ax = ox + JsMath.cos(a0) * rx, ay = oy + JsMath.sin(a0) * ry;
        if (cur == null || JsMath.hypot(ax - cx, ay - cy) > 0.8) cur = null;
        final n = math.max(
          6,
          (((a1 - a0).abs() * math.max(rx, ry)) / step).ceil(),
        );
        for (var k = 0; k <= n; k++) {
          final a = a0 + ((a1 - a0) * k) / n;
          push(
            ox + JsMath.cos(a) * rx,
            oy + JsMath.sin(a) * ry,
            k == 0 || k == n,
          );
        }
      case 'Z':
        final s = cur;
        if (s == null || s.pts.length <= 2) break;
        s.shape = s.pts.length;
        final first = s.pts[0], look = s.pts[math.min(3, s.pts.length - 1)];
        final dl = JsMath.or(
          JsMath.hypot(look.x - first.x, look.y - first.y),
          1,
        );
        final ux = (look.x - first.x) / dl, uy = (look.y - first.y) / dl;
        final ov = 0.9 + random() * 1.0;
        push(sx, sy, false);
        push(
          sx + ux * ov * 0.5 - uy * 0.2,
          sy + uy * ov * 0.5 + ux * 0.2,
          false,
        );
        push(sx + ux * ov - uy * 0.45, sy + uy * ov + ux * 0.45, false);
        s.closed = true;
    }
  }
  for (final s in subs) {
    if (s.shape == 0) s.shape = s.pts.length;
  }
  return subs;
}

/// The closed outlines of an art path (sub-paths of more than two points,
/// without their overshoot), sampled every half unit by default.
///
/// Mirrors `polygonsOf` in `src/lib/ink/art/dsl.ts`.
List<List<Pt>> polygonsOf(
  String d, {
  double step = 0.5,
  double Function()? rnd,
}) => [
  for (final s in parsePath(d, step: step, rnd: rnd))
    if (s.pts.length > 2) s.pts.sublist(0, s.shape),
];
