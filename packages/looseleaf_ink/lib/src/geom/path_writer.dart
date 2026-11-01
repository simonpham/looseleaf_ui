import 'package:looseleaf_ink/src/core/core.dart';

/// Writes compact relative SVG path data on a `1/q` grid.
///
/// Mirrors `PathWriter` in `src/lib/ink/geom.ts`.
final class PathWriter {
  /// A writer on the `1/q` grid.
  PathWriter(this.q);

  /// The path data written so far.
  String d = '';

  /// Grid units per pixel.
  final int q;

  String _cmd = '';
  int _px = 0;
  int _py = 0;
  int _sx = 0;
  int _sy = 0;
  String _lastNum = '';

  int _u(double v) {
    if (!v.isFinite) return 0;
    return JsMath.roundInt(v * q);
  }

  void _num(int k) {
    final s = fmtUnits(k, q);
    if (_lastNum.isNotEmpty) {
      final c = s.codeUnitAt(0);
      final joins = c == 45 || (c == 46 && _lastNum.contains('.'));
      if (!joins) d += ' ';
    }
    d += s;
    _lastNum = s;
  }

  void _letter(String c) {
    if (_cmd == c) return;
    d += c;
    _cmd = c;
    _lastNum = '';
  }

  /// Move to.
  PathWriter m(double x, double y) {
    final ux = _u(x), uy = _u(y);
    d += 'M';
    _cmd = 'M';
    _lastNum = '';
    _num(ux);
    _num(uy);
    _px = _sx = ux;
    _py = _sy = uy;
    return this;
  }

  /// Line to.
  PathWriter l(double x, double y) {
    final ux = _u(x), uy = _u(y);
    _letter('l');
    _num(ux - _px);
    _num(uy - _py);
    _px = ux;
    _py = uy;
    return this;
  }

  /// Quadratic curve to.
  PathWriter quad(double cx, double cy, double x, double y) {
    final ucx = _u(cx), ucy = _u(cy), ux = _u(x), uy = _u(y);
    _letter('q');
    _num(ucx - _px);
    _num(ucy - _py);
    _num(ux - _px);
    _num(uy - _py);
    _px = ux;
    _py = uy;
    return this;
  }

  /// Close path.
  PathWriter z() {
    d += 'z';
    _cmd = 'z';
    _lastNum = '';
    _px = _sx;
    _py = _sy;
    return this;
  }
}
