import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/charts/xy_geometry.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Label sizes of an XY chart.
typedef XYMetrics = ({LabelFont font, double tick, double value, double note});

/// What note placement needs from the XY layout.
typedef XYScene = ({
  XYSpec spec,
  XYMetrics m,
  List<XYBar> bars,
  List<XYDot> dots,
  List<XYLine> lines,
  List<XYArea> areas,
  List<ChartLabel> labels,
  bool wantsValues,
  bool horizontal,
  double x0,
  double w,
  double h,
});

double _crowd(XYScene c, double l0, double t0, double l1, double t1) {
  var hits = 0.0;
  for (final l in c.lines) {
    for (final sg in l.segs) {
      for (var k = 0; k < sg.length; k += 2) {
        final p = sg[k];
        if (p.x >= l0 && p.x <= l1 && p.y >= t0 && p.y <= t1) hits++;
      }
    }
  }
  for (final b in c.bars) {
    final ox = math.min(l1, b.x + b.w) - math.max(l0, b.x);
    final oy = math.min(t1, b.y + b.h) - math.max(t0, b.y);
    if (ox > 0 && oy > 0) hits += 3 + (ox * oy) / 40;
  }
  for (final d in c.dots) {
    if (d.x >= l0 && d.x <= l1 && d.y >= t0 && d.y <= t1) hits += 2;
  }
  for (final a in c.areas) {
    final l = c.lines.where((q) => q.s == a.s).firstOrNull;
    if (l == null) continue;
    final mx = (l0 + l1) / 2;
    for (final sg in l.segs) {
      final i = sg.indexWhere((p) => p.x >= mx);
      if (i > 0 && sg[i].x > sg[i - 1].x) {
        final t = (mx - sg[i - 1].x) / (sg[i].x - sg[i - 1].x);
        final yc = sg[i - 1].y + (sg[i].y - sg[i - 1].y) * t;
        if (t1 > yc - 2) hits += 5;
      }
    }
  }
  for (final q in c.labels) {
    if (q.role == LabelRole.note || q.role == LabelRole.center) continue;
    final size = q.size ?? c.m.tick;
    final qw = textWidth(q.text, size, c.m.font);
    final qx0 = switch (q.anchor) {
      LabelAnchor.start => q.x,
      LabelAnchor.end => q.x - qw,
      LabelAnchor.middle => q.x - qw / 2,
    };
    final qy0 = switch (q.valign) {
      LabelValign.top => q.y,
      LabelValign.bottom => q.y - size,
      LabelValign.middle => q.y - size / 2,
    };
    if (qx0 < l1 && qx0 + qw > l0 && qy0 < t1 && qy0 + size > t0) hits += 6;
  }
  return hits;
}

({Pt target, double rx, double ry})? _targetOf(XYScene c, XYNote note) {
  final m = c.m;
  final bar = c.bars.where((b) => b.s == note.s && b.i == note.i).firstOrNull;
  if (bar != null) {
    final text = c.spec.valueLabels
        ?.elementAtOrNull(bar.s)
        ?.elementAtOrNull(bar.i);
    final labelled = c.wantsValues && text != null && text.isNotEmpty;
    if (c.horizontal) {
      final reach = switch (labelled) {
        true => 12.0,
        false => 0.0,
      };
      final tx = switch (bar.neg) {
        true => bar.x,
        false => bar.x + bar.w + reach,
      };
      return (
        target: (tx, bar.y + bar.h / 2),
        rx: switch (labelled) {
          true => 18.0,
          false => 10.0,
        },
        ry: math.max(10.0, bar.h / 2 + 6),
      );
    }
    final lift = switch (labelled) {
      true => m.value * 0.7,
      false => 0.0,
    };
    final edge = switch (bar.neg) {
      true => bar.y + bar.h,
      false => bar.y,
    };
    return (
      target: (bar.x + bar.w / 2, edge - lift),
      rx: math.max(
        switch (labelled) {
          true => 15.0,
          false => 11.0,
        },
        bar.w / 2 + 7,
      ),
      ry: switch (labelled) {
        true => 15.0,
        false => 10.0,
      },
    );
  }
  final dot = c.dots.where((d) => d.s == note.s && d.i == note.i).firstOrNull;
  if (dot != null) {
    return (target: (dot.x, dot.y), rx: dot.r + 7, ry: dot.r + 7);
  }
  final line = c.lines.where((l) => l.s == note.s).firstOrNull;
  if (line?.pts.elementAtOrNull(note.i) case final p?) {
    return (target: p, rx: 11.0, ry: 10.0);
  }
  return null;
}

LabelTone _tone(NotePen pen) => switch (pen) {
  NotePen.red => LabelTone.red,
  NotePen.green => LabelTone.green,
  NotePen.blue => LabelTone.blue,
  NotePen.ink => LabelTone.ink,
};

/// Places each annotation's text where it crowds the drawing least,
/// adding its label to the scene's labels, and returns the marks.
///
/// Mirrors the notes pass of `layoutXY` in `src/lib/ink/charts/chart-xy.ts`.
List<XYNoteGeom> placeNotes(XYScene c) {
  final m = c.m;
  final out = <XYNoteGeom>[];
  for (final (ni, note) in c.spec.notes.indexed) {
    final hit = _targetOf(c, note);
    if (hit == null) continue;
    final tgt = hit.target;
    final tw = textWidth(note.text, m.note, m.font);
    final th = m.note * 1.1;
    final pinned = note.dx != null || note.dy != null;
    const up = -38.0;
    final down = 44 + th;
    final near = tw / 2 + 40;
    final cands = switch (pinned) {
      true => [(note.dx ?? near, note.dy ?? up)],
      false => [
        (near, up),
        (-near, up),
        (near, -28.0),
        (-near, -28.0),
        (near, down),
        (-near, down),
        (0.0, up - 14),
        (0.0, down + 12),
      ],
    };
    var lx = 0.0, ly = 0.0, score = double.infinity;
    for (final (ci, (cdx, cdy)) in cands.indexed) {
      final rawX = tgt.x + cdx;
      final rawY = tgt.y + cdy;
      final cx = clampN(
        rawX,
        math.min(c.x0 + tw / 2 + 2, c.w / 2),
        c.w - tw / 2 - 4,
      );
      final cy = clampN(rawY, th + 2, c.h - 4);
      final s =
          (cx - rawX).abs() * 0.35 +
          (cy - rawY).abs() * 0.35 +
          _crowd(c, cx - tw / 2 - 3, cy - th - 2, cx + tw / 2 + 3, cy + 4) * 2 +
          ci * 0.4;
      if (s < score) {
        lx = cx;
        ly = cy;
        score = s;
      }
    }
    final dx = lx - tgt.x;
    final dy = ly - tgt.y;
    final sx =
        lx +
        switch (dx > 0) {
          true => -tw / 2 - 4,
          false => tw / 2 + 4,
        };
    final sy =
        ly -
        switch (dy < 0) {
          true => -2,
          false => th + 2,
        };
    final ang = JsMath.atan2(sy - tgt.y, sx - tgt.x);
    final ex = tgt.x + JsMath.cos(ang) * (hit.rx + 3);
    final ey = tgt.y + JsMath.sin(ang) * (hit.ry + 3);
    final far = JsMath.hypot(sx - ex, sy - ey) > 14;
    c.labels.add(
      ChartLabel(
        id: 'note-$ni',
        text: note.text,
        x: lx,
        y: ly,
        anchor: LabelAnchor.middle,
        valign: LabelValign.bottom,
        role: LabelRole.note,
        size: m.note,
        tone: _tone(note.pen),
      ),
    );
    out.add(
      XYNoteGeom(
        n: ni,
        pen: note.pen,
        shape: note.shape,
        loop: switch (note.shape) {
          NoteShape.loop => (cx: tgt.x, cy: tgt.y, rx: hit.rx, ry: hit.ry),
          _ => null,
        },
        underline: switch (note.shape) {
          NoteShape.underline => (
            x1: lx - tw / 2 - 2,
            x2: lx + tw / 2 + 2,
            y: ly + 3,
          ),
          _ => null,
        },
        arrow: switch (far) {
          true => (x1: sx, y1: sy, x2: ex, y2: ey),
          false => null,
        },
      ),
    );
  }
  return out;
}
