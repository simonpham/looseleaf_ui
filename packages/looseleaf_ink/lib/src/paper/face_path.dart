import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';

String _num(double v) => JsMath.numberToString(JsMath.round(v * 100) / 100);

const Map<String, int> _arity = {
  'm': 2,
  'l': 2,
  'h': 1,
  'v': 1,
  'c': 6,
  's': 4,
  'q': 4,
  't': 2,
  'a': 7,
};

final class _Seg {
  const _Seg(this.cmd, this.args);

  final String cmd;
  final List<double> args;
}

final RegExp _token = RegExp(r'[a-zA-Z]|-?\d*\.?\d+(?:e[-+]?\d+)?');
final RegExp _letter = RegExp('[a-zA-Z]');
final RegExp _upper = RegExp('[A-Z]');

List<_Seg>? _parsePath(String d) {
  final tokens = [for (final m in _token.allMatches(d)) m[0] ?? ''];
  final out = <_Seg>[];
  var cmd = '';
  var i = 0;
  while (i < tokens.length) {
    if (_letter.hasMatch(tokens[i])) {
      cmd = tokens[i++];
      if (cmd == 'z' || cmd == 'Z') {
        out.add(_Seg(cmd, const []));
        continue;
      }
    }
    final n = _arity[cmd.toLowerCase()] ?? 0;
    if (n == 0 || i + n > tokens.length) return null;
    final args = [
      for (final t in tokens.sublist(i, i + n))
        double.tryParse(t) ?? double.nan,
    ];
    if (args.any((x) => x.isNaN)) return null;
    i += n;
    out.add(_Seg(cmd, args));
    if (cmd == 'M') cmd = 'L';
    if (cmd == 'm') cmd = 'l';
  }
  return out;
}

final RegExp _leadMove = RegExp(
  r'^\s*M\s*(-?(?:\d+\.?\d*|\.\d+))[\s,]*(-?(?:\d+\.?\d*|\.\d+))',
);
final RegExp _numStart = RegExp(r'^[.\d-]');

/// Moves path [d] by `(dx, dy)`, rewriting absolute commands only.
///
/// Mirrors `translatePath` in `src/lib/ink/paper/faces.ts`.
String translatePath(String d, double dx, double dy) {
  if (_leadMove.firstMatch(d) case final m?) {
    final rest = d.substring(m.end);
    if (!_upper.hasMatch(rest)) {
      final x = double.parse(m[1] ?? '0') + dx;
      final y = double.parse(m[2] ?? '0') + dy;
      final gap = switch (_numStart.hasMatch(rest)) {
        true => ' ',
        false => '',
      };
      return 'M${_num(x)} ${_num(y)}$gap$rest';
    }
  }
  final segs = _parsePath(d);
  if (segs == null) return d;
  var last = '';
  final out = StringBuffer();
  for (final (k, seg) in segs.indexed) {
    final cmd = seg.cmd;
    final a = [...seg.args];
    final lower = cmd.toLowerCase();
    if (cmd == cmd.toUpperCase() || (k == 0 && cmd == 'm')) {
      _shift(a, lower, dx, dy);
    }
    final same = cmd == last && lower != 'm';
    last = cmd;
    out.write(switch (same) {
      true => ' ',
      false => cmd,
    });
    out.write(a.map(_num).join(' '));
  }
  return out.toString();
}

void _shift(List<double> a, String lower, double dx, double dy) {
  if (lower == 'h') {
    a[0] += dx;
    return;
  }
  if (lower == 'v') {
    a[0] += dy;
    return;
  }
  if (lower == 'a') {
    a[5] += dx;
    a[6] += dy;
    return;
  }
  for (var j = 0; j < a.length; j += 2) {
    a[j] += dx;
    a[j + 1] += dy;
  }
}

double _ang(double ux, double uy, double vx, double vy) =>
    JsMath.atan2(ux * vy - uy * vx, ux * vx + uy * vy);

List<Pt> _arcPoints(
  double x1,
  double y1,
  double rx0,
  double ry0,
  double rot,
  double large,
  double sweep,
  double x2,
  double y2,
) {
  var rx = rx0.abs();
  var ry = ry0.abs();
  if (rx == 0 || rx.isNaN || ry == 0 || ry.isNaN || (x1 == x2 && y1 == y2)) {
    return [(x2, y2)];
  }
  final phi = (rot * JsMath.pi) / 180;
  final c = JsMath.cos(phi), s = JsMath.sin(phi);
  final dx = (x1 - x2) / 2, dy = (y1 - y2) / 2;
  final x1p = c * dx + s * dy, y1p = -s * dx + c * dy;
  final lam = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
  if (lam > 1) {
    rx *= JsMath.sqrt(lam);
    ry *= JsMath.sqrt(lam);
  }
  final num2 = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p;
  final den = rx * rx * y1p * y1p + ry * ry * x1p * x1p;
  final sign = switch (large == sweep) {
    true => -1.0,
    false => 1.0,
  };
  final k = sign * JsMath.sqrt(math.max(0, num2 / den));
  final cxp = (k * rx * y1p) / ry, cyp = (-k * ry * x1p) / rx;
  final cx = c * cxp - s * cyp + (x1 + x2) / 2;
  final cy = s * cxp + c * cyp + (y1 + y2) / 2;
  final t1 = _ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
  var dt = _ang(
    (x1p - cxp) / rx,
    (y1p - cyp) / ry,
    (-x1p - cxp) / rx,
    (-y1p - cyp) / ry,
  );
  final sweeps = sweep != 0 && !sweep.isNaN;
  if (!sweeps && dt > 0) dt -= 2 * JsMath.pi;
  if (sweeps && dt < 0) dt += 2 * JsMath.pi;
  return [
    for (var i = 1; i <= 16; i++)
      _arcAt(t1 + (dt * i) / 16, cx, cy, rx, ry, c, s),
  ];
}

Pt _arcAt(
  double t,
  double cx,
  double cy,
  double rx,
  double ry,
  double c,
  double s,
) => (
  cx + rx * JsMath.cos(t) * c - ry * JsMath.sin(t) * s,
  cy + rx * JsMath.cos(t) * s + ry * JsMath.sin(t) * c,
);

/// The bounding box `[x0, y0, x1, y1]` of path [d] (control points and
/// sampled arcs included), or zeros.
///
/// Mirrors `pathBox` in `src/lib/ink/paper/faces.ts`.
List<double> pathBox(String d) {
  final segs = _parsePath(d) ?? const <_Seg>[];
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  final box = BBox.empty();
  for (final seg in segs) {
    final cmd = seg.cmd;
    final args = seg.args;
    final rel = cmd != cmd.toUpperCase();
    final lower = cmd.toLowerCase();
    if (lower == 'z') {
      x = sx;
      y = sy;
      continue;
    }
    final ox = switch (rel) {
      true => x,
      false => 0.0,
    };
    final oy = switch (rel) {
      true => y,
      false => 0.0,
    };
    switch (lower) {
      case 'h':
        x = ox + args[0];
      case 'v':
        y = oy + args[0];
      case 'a':
        final ex = ox + args[5], ey = oy + args[6];
        for (final (px, py) in _arcPoints(
          x,
          y,
          args[0],
          args[1],
          args[2],
          args[3],
          args[4],
          ex,
          ey,
        )) {
          box.grow(px, py);
        }
        x = ex;
        y = ey;
      default:
        for (var j = 0; j < args.length - 2; j += 2) {
          box.grow(ox + args[j], oy + args[j + 1]);
        }
        x = ox + args[args.length - 2];
        y = oy + args[args.length - 1];
    }
    if (lower == 'm') {
      sx = x;
      sy = y;
    }
    box.grow(x, y);
  }
  if (!box.x0.isFinite) return [0, 0, 0, 0];
  return box.toList();
}
