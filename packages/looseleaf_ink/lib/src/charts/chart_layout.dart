import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_spec.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Lays out any chart in [box]; [calm] uses the quieter hand font.
///
/// Mirrors `layoutChart` in `src/lib/ink/charts/chart-layout.ts`.
ChartLayoutBase layoutChart(ChartSpec spec, Box box, [bool calm = false]) =>
    spec.layout(box, calm);

double _norm(double a) => ((a.remainder(tau)) + tau).remainder(tau);

/// The target under `(x, y)`, or null.
///
/// Mirrors `hitIndex` in `src/lib/ink/charts/chart-layout.ts`.
int? hitIndex(ChartTargets t, double x, double y) {
  if (t.n <= 0) return null;
  switch (t.mode) {
    case TargetMode.x || TargetMode.y:
      final pos = t.pos ?? const <double>[];
      final v = switch (t.mode) {
        TargetMode.x => x,
        _ => y,
      };
      var best = -1;
      var bd = double.infinity;
      for (var i = 0; i < pos.length; i++) {
        final d = (pos[i] - v).abs();
        if (d < bd) {
          bd = d;
          best = i;
        }
      }
      if (best < 0) return null;
      return best;
    case TargetMode.point:
      var best = -1;
      var bd = 40.0 * 40;
      for (var i = 0; i < t.n; i++) {
        final dx = t.cx[i] - x;
        final dy = t.cy[i] - y;
        final d = dx * dx + dy * dy;
        if (d < bd) {
          bd = d;
          best = i;
        }
      }
      if (best < 0) return null;
      return best;
    case TargetMode.sector:
      final s = t.sector;
      if (s == null) return null;
      final r = JsMath.hypot(x - s.cx, y - s.cy);
      final ang = JsMath.atan2(x - s.cx, s.cy - y);
      for (var i = 0; i < t.n; i++) {
        if (r < s.r0[i] || r > s.r1[i]) continue;
        final span = s.a1[i] - s.a0[i];
        if (_norm(ang - s.a0[i]) <= span + 1e-9) return i;
      }
      return null;
    case TargetMode.cell:
      final c = t.cells;
      if (c == null) return null;
      final col = ((x - c.x0) / c.cw).floor();
      final row = ((y - c.y0) / c.ch).floor();
      if (col < 0 || row < 0 || col >= c.cols || row >= c.rows) return null;
      final k = row * c.cols + col;
      if (k >= c.index.length || c.index[k] < 0) return null;
      return k;
  }
}

int _firstCell(ChartTargets t) {
  final i = t.cells?.index.indexWhere((k) => k >= 0) ?? 0;
  return math.max(0, i);
}

int _lastCell(ChartTargets t) {
  final idx = t.cells?.index ?? const <int>[];
  for (var i = idx.length - 1; i >= 0; i--) {
    if (idx[i] >= 0) return i;
  }
  return 0;
}

(int, int)? _cellStep(String key) => switch (key) {
  'ArrowRight' => (1, 0),
  'ArrowLeft' => (-1, 0),
  'ArrowDown' => (0, 1),
  'ArrowUp' => (0, -1),
  'PageDown' => (7, 0),
  'PageUp' => (-7, 0),
  _ => null,
};

int? _stepCell(ChartTargets t, CellTargets c, int? cur, String key) {
  final d = _cellStep(key);
  if (d == null) return null;
  if (cur == null) return _firstCell(t);
  var col = cur % c.cols;
  var row = cur ~/ c.cols;
  for (var guard = 0; guard < c.cols + c.rows; guard++) {
    col += d.$1;
    row += d.$2;
    if (col < 0 || row < 0 || col >= c.cols || row >= c.rows) return cur;
    final k = row * c.cols + col;
    if (k < c.index.length && c.index[k] >= 0) return k;
  }
  return cur;
}

/// The target a key press moves to from [from] (Home, End, arrows, and
/// PageUp/PageDown by a week on calendars), or null.
///
/// Mirrors `stepIndex` in `src/lib/ink/charts/chart-layout.ts`.
int? stepIndex(ChartTargets t, int? from, String key) {
  final n = t.n;
  if (n <= 0) return null;
  final cur = switch (from) {
    final f? when f >= 0 && f < n => f,
    _ => null,
  };
  final cellMode = t.mode == TargetMode.cell;
  if (key == 'Home') {
    return switch (cellMode) {
      true => _firstCell(t),
      false => 0,
    };
  }
  if (key == 'End') {
    return switch (cellMode) {
      true => _lastCell(t),
      false => n - 1,
    };
  }
  if (t.cells case final c? when cellMode) return _stepCell(t, c, cur, key);
  final forward = switch (t.mode) {
    TargetMode.y => key == 'ArrowDown',
    TargetMode.sector => key == 'ArrowRight' || key == 'ArrowDown',
    _ => key == 'ArrowRight',
  };
  final backward = switch (t.mode) {
    TargetMode.y => key == 'ArrowUp',
    TargetMode.sector => key == 'ArrowLeft' || key == 'ArrowUp',
    _ => key == 'ArrowLeft',
  };
  if (!forward && !backward) return null;
  final delta = switch (forward) {
    true => 1,
    false => -1,
  };
  if (cur == null) {
    return switch (forward) {
      true => 0,
      false => n - 1,
    };
  }
  if (t.mode == TargetMode.sector) return (cur + delta + n) % n;
  return math.max(0, math.min(n - 1, cur + delta));
}
