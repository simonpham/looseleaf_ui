import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/charts/xy_geometry.dart';
import 'package:looseleaf_ink/src/charts/xy_marks.dart';
import 'package:looseleaf_ink/src/charts/xy_notes.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';
import 'package:looseleaf_ink/src/charts/xy_ticks.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

XYMetrics _metricsFor(Bucket bucket, bool calm) {
  if (calm) {
    return (font: LabelFont.hand, tick: 12.5, value: 12.0, note: 15.0);
  }
  return (
    font: LabelFont.script,
    tick: switch (bucket) {
      Bucket.sm => 14.0,
      Bucket.md => 15.0,
      Bucket.lg => 16.0,
    },
    value: switch (bucket) {
      Bucket.lg => 16.0,
      _ => 15.0,
    },
    note: switch (bucket) {
      Bucket.sm => 18.0,
      _ => 20.0,
    },
  );
}

double _widest(Iterable<String> texts, XYMetrics m) =>
    texts.fold(0.0, (b, t) => math.max(b, textWidth(t, m.tick, m.font)));

bool _fitsValues(
  XYSpec spec,
  XYMetrics m,
  Bucket bucket,
  bool horizontal,
  double w,
  double h,
) {
  final labels = spec.valueLabels;
  if (labels == null || spec.values == false) return false;
  if (spec.values == true) return true;
  if (spec.stacked || bucket == Bucket.sm) return false;
  final barSeriesCount = spec.series.where((s) => s.kind == XYKind.bar).length;
  if (barSeriesCount == 0) return false;
  final across = switch (horizontal) {
    true => h,
    false => w,
  };
  final slotLen = across / math.max(1, spec.cats.length) / barSeriesCount;
  final widest = labels
      .expand((row) => row)
      .fold(
        1.0,
        (b, t) => math.max(b, switch (t) {
          final text? when text.isNotEmpty => textWidth(text, m.value, m.font),
          _ => 0.0,
        }),
      );
  if (horizontal) return slotLen >= m.value;
  return slotLen >= 28 && widest <= slotLen * 0.75;
}

/// Lays out a bar, line, area or scatter chart in [box]: plot area,
/// bars, lines, areas, dots, axis labels, value labels, bands,
/// annotations, reference lines, targets and cursors.
///
/// Mirrors `layoutXY` in `src/lib/ink/charts/chart-xy.ts`.
XYLayout layoutXY(XYSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final m = _metricsFor(bucket, calm);
  final horizontal = isHorizontal(spec);
  final scatter = spec.series.any((s) => s.kind == XYKind.scatter);
  final n = spec.cats.length;
  final hasBars = spec.series.any((s) => s.kind == XYKind.bar);
  final labels = <ChartLabel>[];
  final empty =
      spec.state != ChartState.ready ||
      (!scatter && n == 0) ||
      spec.series.isEmpty;

  final maxYTicks = switch (horizontal) {
    true => math.max(2, ((w * 0.7) / 54).floor()),
    false => math.max(2, ((h - 60) / 38).floor()),
  };
  final yTicks = pickTicks(
    spec.yTicks,
    spec.yTicksAlt,
    switch (bucket == Bucket.sm && !horizontal) {
      true => math.min(3, maxYTicks),
      false => maxYTicks + 1,
    },
    (spec.yMin, spec.yMax),
  );
  final yLabelW = switch (horizontal) {
    true => math.min(_widest(spec.cats, m), w * 0.36),
    false => _widest(yTicks.map((t) => t.label), m),
  };
  final left = switch (spec.showY) {
    true => yLabelW.ceilToDouble() + 12,
    false => 6.0,
  };
  final wantsValues = !empty && _fitsValues(spec, m, bucket, horizontal, w, h);
  final top =
      xyMargins.top +
      switch (wantsValues && !horizontal) {
        true => m.value + 2,
        false => 0.0,
      } +
      switch (spec.notes.isEmpty) {
        true => 0.0,
        false => 6.0,
      };
  final bottom = switch (spec.showX) {
    true => JsMath.round(m.tick + 14),
    false => 8.0,
  };
  final right =
      xyMargins.right +
      switch (horizontal && wantsValues) {
        true => 26,
        false => 0,
      };
  final x0 = left;
  final x1 = math.max(x0 + 10, w - right);
  final y0 = top;
  final y1 = math.max(y0 + 10, h - bottom);
  final plotW = x1 - x0;
  final plotH = y1 - y0;

  final catLen = switch (horizontal) {
    true => plotH,
    false => plotW,
  };
  final band = switch (n > 0) {
    true => catLen / n,
    false => catLen,
  };

  final vMin = spec.yMin;
  final vSpan = JsMath.or(spec.yMax - vMin, 1);
  double vPos(double v) {
    if (horizontal) {
      return clampN(x0 + ((v - vMin) / vSpan) * plotW, x0 - 6, x1 + 6);
    }
    return clampN(y1 - ((v - vMin) / vSpan) * plotH, y0 - 6, y1 + 6);
  }

  final basePx = vPos(clampN(0, vMin, spec.yMax));
  final centered = hasBars || horizontal;
  final inset = clampN(band * 0.5, 8, 26);
  double catPos(int i) {
    if (horizontal) return y0 + band * (i + 0.5);
    if (centered || n < 2) return x0 + band * (i + 0.5);
    return x0 + inset + ((plotW - 2 * inset) * i) / (n - 1);
  }

  final xMin = spec.xMin ?? 0;
  final xSpan = JsMath.or((spec.xMax ?? 1) - xMin, 1);
  double xNum(double v) =>
      clampN(x0 + ((v - xMin) / xSpan) * plotW, x0 - 6, x1 + 6);

  final frame = XYFrame(
    spec: spec,
    bucket: bucket,
    horizontal: horizontal,
    scatter: scatter,
    empty: empty,
    n: n,
    band: band,
    plotW: plotW,
    catLen: catLen,
    basePx: basePx,
    vPos: vPos,
    catPos: catPos,
    xNum: xNum,
  );
  final barMarks = layoutBars(frame);
  final bars = barMarks.bars;
  final lineMarks = layoutLines(frame);
  final lines = lineMarks.lines;
  final areas = lineMarks.areas;
  final pointMarks = layoutDots(frame, lines);
  final dots = pointMarks.dots;
  final pointOf = pointMarks.pointOf;
  final simplified = math.max(lineMarks.simplified, pointMarks.simplified);

  final gridPx = <double>[];
  if (!empty) {
    if (horizontal) {
      final bottomTicks = [
        for (final t in yTicks)
          (t: t, x: vPos(t.v), w: labelWidth(t.label, m.tick, m.font)),
      ];
      gridPx.addAll(bottomTicks.map((b) => b.x));
      if (spec.showX) {
        for (final b in clearLabels(bottomTicks, (b) => b.x, (b) => b.w)) {
          labels.add(
            ChartLabel(
              id: 'y-${JsMath.numberToString(b.t.v)}',
              text: b.t.label,
              x: b.x,
              y: y1 + 8,
              anchor: LabelAnchor.middle,
              valign: LabelValign.top,
              role: LabelRole.y,
              size: m.tick,
              tone: LabelTone.muted,
            ),
          );
        }
      }
      if (spec.showY) {
        final stride = math.max(1, ((m.tick + 4) / math.max(4, band)).ceil());
        for (var i = 0; i < n; i += stride) {
          labels.add(
            ChartLabel(
              id: 'c-$i',
              text: spec.cats[i],
              x: x0 - 8,
              y: catPos(i),
              anchor: LabelAnchor.end,
              valign: LabelValign.middle,
              role: LabelRole.cat,
              size: m.tick,
              tone: LabelTone.ink,
              maxW: left - 12,
            ),
          );
        }
      }
    }
    if (!horizontal) {
      for (final t in yTicks) {
        final y = vPos(t.v);
        gridPx.add(y);
        if (spec.showY) {
          labels.add(
            ChartLabel(
              id: 'y-${JsMath.numberToString(t.v)}',
              text: t.label,
              x: x0 - 8,
              y: y,
              anchor: LabelAnchor.end,
              valign: LabelValign.middle,
              role: LabelRole.y,
              size: m.tick,
              tone: LabelTone.muted,
            ),
          );
        }
      }
      _xLabels(frame, labels, m, x0, y1, plotW);
    }
  }

  final valueLabels = spec.valueLabels;
  if (wantsValues && valueLabels != null) {
    for (final b in bars) {
      final text = valueLabels.elementAtOrNull(b.s)?.elementAtOrNull(b.i);
      if (text == null || text.isEmpty) continue;
      labels.add(_valueLabel(b, text, horizontal, m));
    }
  }

  final bandGeoms = <XYRect>[];
  if (!empty && !scatter) {
    for (final (bi, b) in spec.bands.indexed) {
      final pad = switch (centered) {
        true => band / 2,
        false => math.min(band / 2, 14.0),
      };
      final lo = catPos(b.i0) - pad;
      final hi = catPos(b.i1) + pad;
      final XYRect g = switch (horizontal) {
        true => (x: x0, y: lo, w: plotW, h: hi - lo),
        false => (x: lo, y: y0, w: hi - lo, h: plotH),
      };
      bandGeoms.add(g);
      if (b.text case final text? when text.isNotEmpty) {
        labels.add(
          ChartLabel(
            id: 'band-$bi',
            text: text,
            x: switch (horizontal) {
              true => x1 - 4,
              false => g.x + 5,
            },
            y: switch (horizontal) {
              true => g.y + 4,
              false => y0 + 3,
            },
            anchor: switch (horizontal) {
              true => LabelAnchor.end,
              false => LabelAnchor.start,
            },
            valign: LabelValign.top,
            role: LabelRole.note,
            size: m.tick,
            tone: LabelTone.ink,
          ),
        );
      }
    }
  }

  final notes = placeNotes((
    spec: spec,
    m: m,
    bars: bars,
    dots: dots,
    lines: lines,
    areas: areas,
    labels: labels,
    wantsValues: wantsValues,
    horizontal: horizontal,
    x0: x0,
    w: w,
    h: h,
  ));

  final refs = <XYRefGeom>[];
  if (!empty) {
    for (final (ri, r) in spec.refs.indexed) {
      final tone = switch (r.pen) {
        NotePen.red => LabelTone.red,
        _ => LabelTone.muted,
      };
      ChartLabel refLabel(
        String text,
        double x,
        double y,
        LabelAnchor anchor,
        LabelValign valign,
      ) => ChartLabel(
        id: 'ref-$ri',
        text: text,
        x: x,
        y: y,
        anchor: anchor,
        valign: valign,
        role: LabelRole.ref,
        size: m.tick,
        tone: tone,
      );
      final label = r.label;
      final named = label != null && label.isNotEmpty;
      if (r.axis == RefAxis.y && horizontal) {
        final p = vPos(r.value);
        refs.add((x1: p, y1: y0 - 2, x2: p, y2: y1, pen: r.pen));
        if (named) {
          labels.add(
            refLabel(
              label,
              p + 4,
              y0 - 2,
              LabelAnchor.start,
              LabelValign.bottom,
            ),
          );
        }
        continue;
      }
      if (r.axis == RefAxis.y) {
        final p = vPos(r.value);
        refs.add((x1: x0, y1: p, x2: x1, y2: p, pen: r.pen));
        if (named) {
          labels.add(
            refLabel(label, x1 - 2, p - 3, LabelAnchor.end, LabelValign.bottom),
          );
        }
        continue;
      }
      if (!scatter) continue;
      final p = xNum(r.value);
      refs.add((x1: p, y1: y0, x2: p, y2: y1, pen: r.pen));
      if (named) {
        labels.add(
          refLabel(label, p + 4, y0 + 2, LabelAnchor.start, LabelValign.top),
        );
      }
    }
  }

  if (spec.state != ChartState.ready || (empty && spec.stateText != null)) {
    final at = switch (spec.state == ChartState.loading) {
      true => 0.16,
      false => 0.38,
    };
    labels.add(
      ChartLabel(
        id: 'state',
        text: stateTextOf(spec.stateText, spec.state == ChartState.loading),
        x: (x0 + x1) / 2,
        y: y0 + (y1 - y0) * at,
        anchor: LabelAnchor.middle,
        valign: LabelValign.middle,
        role: LabelRole.center,
        size: m.note,
        tone: LabelTone.muted,
      ),
    );
  }

  final targets = switch (scatter) {
    true => ChartTargets(
      n: pointOf.length,
      mode: TargetMode.point,
      cx: pointMarks.tx,
      cy: pointMarks.ty,
      nav: TargetNav.linear,
    ),
    false => _catTargets(frame, bars, lines, x0, y1),
  };

  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= targets.n) return const [];
    if (scatter) {
      final at = pointOf[i];
      final d = dots.where((q) => q.s == at.s && q.i == at.j).firstOrNull;
      if (d == null) return const [];
      return [
        CursorSpec(
          kind: CursorKind.ring,
          x: d.x - d.r - 6,
          y: d.y - d.r - 6,
          w: 2 * d.r + 12,
          h: 2 * d.r + 12,
          slot: spec.series[d.s].slot,
        ),
      ];
    }
    final c = targets.pos?.elementAtOrNull(i) ?? 0;
    final out = <CursorSpec>[
      if (hasBars && horizontal)
        CursorSpec(
          kind: CursorKind.column,
          x: x0,
          y: c - band / 2,
          w: plotW,
          h: band,
        ),
      if (hasBars && !horizontal)
        CursorSpec(
          kind: CursorKind.column,
          x: c - band / 2,
          y: y0,
          w: band,
          h: plotH,
        ),
      if (!hasBars && !horizontal)
        CursorSpec(kind: CursorKind.guide, x: c - 5, y: y0, w: 10, h: plotH),
    ];
    if (horizontal) return out;
    for (final l in lines) {
      if (series != null && series != l.s) continue;
      if (l.pts.elementAtOrNull(i) case (final px, final py)) {
        out.add(
          CursorSpec(
            kind: CursorKind.ring,
            x: px - 9,
            y: py - 9,
            w: 18,
            h: 18,
            slot: spec.series[l.s].slot,
          ),
        );
      }
    }
    return out;
  }

  return XYLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    plot: (x0: x0, y0: y0, x1: x1, y1: y1),
    horizontal: horizontal,
    band: band,
    gridPx: gridPx,
    basePx: basePx,
    bars: bars,
    lines: lines,
    areas: areas,
    dots: dots,
    notes: notes,
    refs: refs,
    bands: bandGeoms,
    barW: barMarks.barW,
    pointOf: pointOf,
    simplified: simplified,
  );
}

void _xLabels(
  XYFrame f,
  List<ChartLabel> labels,
  XYMetrics m,
  double x0,
  double y1,
  double plotW,
) {
  final spec = f.spec;
  if (!spec.showX) return;
  final xTicks = spec.xTicks;
  if (f.scatter && xTicks != null) {
    final xt = [
      for (final t in pickTicks(
        xTicks,
        spec.xTicksAlt,
        math.max(2, (plotW / 64).floor()),
        (spec.xMin ?? 0, spec.xMax ?? 1),
      ))
        (t: t, x: f.xNum(t.v), w: labelWidth(t.label, m.tick, m.font)),
    ];
    for (final e in clearLabels(xt, (e) => e.x, (e) => e.w)) {
      labels.add(
        ChartLabel(
          id: 'x-${JsMath.numberToString(e.t.v)}',
          text: e.t.label,
          x: e.x,
          y: y1 + 8,
          anchor: LabelAnchor.middle,
          valign: LabelValign.top,
          role: LabelRole.x,
          size: m.tick,
          tone: LabelTone.ink,
        ),
      );
    }
    return;
  }
  final n = f.n;
  if (f.scatter || n == 0) return;
  final pitch = switch (n > 1) {
    true => (f.catPos(n - 1) - f.catPos(0)) / (n - 1),
    false => f.band,
  };
  final pick = pickLabelIndices(
    [for (final c in spec.cats) labelWidth(c, m.tick, m.font)],
    pitch,
  );
  for (final i in pick.idx) {
    labels.add(
      ChartLabel(
        id: 'x-$i',
        text: spec.cats[i],
        x: f.catPos(i),
        y: y1 + 8,
        anchor: LabelAnchor.middle,
        valign: LabelValign.top,
        role: LabelRole.x,
        size: m.tick,
        tone: LabelTone.ink,
        maxW: math.max(pitch * pick.stride, 12.0),
      ),
    );
  }
}

ChartLabel _valueLabel(XYBar b, String text, bool horizontal, XYMetrics m) {
  if (horizontal) {
    return ChartLabel(
      id: 'v-${b.s}-${b.i}',
      text: text,
      x: switch (b.neg) {
        true => b.x - 5,
        false => b.x + b.w + 5,
      },
      y: b.y + b.h / 2,
      anchor: switch (b.neg) {
        true => LabelAnchor.end,
        false => LabelAnchor.start,
      },
      valign: LabelValign.middle,
      role: LabelRole.value,
      size: m.value,
      tone: LabelTone.ink,
    );
  }
  return ChartLabel(
    id: 'v-${b.s}-${b.i}',
    text: text,
    x: b.x + b.w / 2,
    y: switch (b.neg) {
      true => b.y + b.h + 4,
      false => b.y - 4,
    },
    anchor: LabelAnchor.middle,
    valign: switch (b.neg) {
      true => LabelValign.top,
      false => LabelValign.bottom,
    },
    role: LabelRole.value,
    size: m.value,
    tone: LabelTone.ink,
  );
}

ChartTargets _catTargets(
  XYFrame f,
  List<XYBar> bars,
  List<XYLine> lines,
  double x0,
  double y1,
) {
  final horizontal = f.horizontal;
  final pos = <double>[];
  final cx = <double>[];
  final cy = <double>[];
  for (var i = 0; i < f.n; i++) {
    final c = f.catPos(i);
    pos.add(c);
    var best = switch (horizontal) {
      true => x0,
      false => y1,
    };
    var seen = false;
    for (final b in bars) {
      if (b.i != i) continue;
      final edge = switch ((horizontal, b.neg)) {
        (true, true) => b.x,
        (true, false) => b.x + b.w,
        (false, true) => b.y + b.h,
        (false, false) => b.y,
      };
      best = switch ((seen, horizontal)) {
        (false, _) => edge,
        (true, true) => math.max(best, edge),
        (true, false) => math.min(best, edge),
      };
      seen = true;
    }
    for (final l in lines) {
      if (l.pts.elementAtOrNull(i) case (_, final py)) {
        best = switch (seen) {
          true => math.min(best, py),
          false => py,
        };
        seen = true;
      }
    }
    final at = switch (seen) {
      true => best,
      false => switch (horizontal) {
        true => x0,
        false => y1,
      },
    };
    cx.add(switch (horizontal) {
      true => at,
      false => c,
    });
    cy.add(switch (horizontal) {
      true => c,
      false => at,
    });
  }
  return ChartTargets(
    n: f.n,
    mode: switch (horizontal) {
      true => TargetMode.y,
      false => TargetMode.x,
    },
    pos: pos,
    cx: cx,
    cy: cy,
    nav: TargetNav.linear,
  );
}
