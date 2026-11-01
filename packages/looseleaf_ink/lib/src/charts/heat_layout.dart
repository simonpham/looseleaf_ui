import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/mini_specs.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One heatmap cell.
///
/// Mirrors `HeatCell` in `src/lib/ink/charts/chart-mini.ts`.
final class HeatCell {
  /// A cell.
  const HeatCell(this.col, this.row, this.x, this.y, this.level);

  /// Column.
  final int col;

  /// Row.
  final int row;

  /// Left.
  final double x;

  /// Top.
  final double y;

  /// Level, `0..levelCount-1`.
  final int level;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'col': col,
    'row': row,
    'x': x,
    'y': y,
    'level': level,
  };
}

/// A laid out heatmap.
///
/// Mirrors `HeatLayout` in `src/lib/ink/charts/chart-mini.ts`.
final class HeatLayout extends ChartLayoutBase {
  /// A layout.
  const HeatLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.cs,
    required this.cell,
    required this.gx,
    required this.gy,
    required this.cells,
    required this.legend,
  });

  /// Cell pitch.
  final double cs;

  /// Cell size (pitch less the gap).
  final double cell;

  /// Grid left.
  final double gx;

  /// Grid top.
  final double gy;

  /// The drawn cells.
  final List<HeatCell> cells;

  /// The legend's first swatch and swatch size.
  final ({double x, double y, double cell})? legend;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'cs': cs,
    'cell': cell,
    'gx': gx,
    'gy': gy,
    'cells': [for (final c in cells) c.toJson()],
    'legend': switch (legend) {
      final l? => {'x': l.x, 'y': l.y, 'cell': l.cell},
      null => null,
    },
  };
}

/// Lays out a heatmap in [box].
///
/// Mirrors `layoutHeat` in `src/lib/ink/charts/chart-mini.ts`.
HeatLayout layoutHeat(HeatSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final font = switch (calm) {
    true => LabelFont.hand,
    false => LabelFont.script,
  };
  final tick = switch ((calm, bucket)) {
    (true, _) => 12.0,
    (false, Bucket.sm) => 13.0,
    _ => 14.5,
  };
  final labels = <ChartLabel>[];
  final left = switch (spec.rowLabels.isEmpty) {
    true => 4.0,
    false =>
      spec.rowLabels
              .map((r) => textWidth(r.text, tick, font))
              .reduce(math.max) +
          10,
  };
  final top = switch (spec.colLabels.isEmpty) {
    true => 4.0,
    false => tick + 8,
  };
  final bottom = switch (spec.legend) {
    null => 4.0,
    _ => tick + 16,
  };
  final availW = w - left - 4;
  final availH = h - top - bottom;
  final cs = math.max(
    4.0,
    math.min(
      math.min(
        availW / math.max(1, spec.cols),
        availH / math.max(1, spec.rows),
      ),
      34.0,
    ),
  );
  final gap = clampN(cs * 0.16, 1.4, 4.5);
  final cell = cs - gap;
  final gx = left;
  final gy = top + math.max(0.0, (availH - cs * spec.rows) / 2);
  final cells = <HeatCell>[];
  final index = <int>[];
  for (final (k, lv) in spec.levels.indexed) {
    final col = k % spec.cols;
    final row = k ~/ spec.cols;
    if (lv >= 0) {
      cells.add(HeatCell(col, row, gx + col * cs, gy + row * cs, lv));
    }
    index.add(switch (lv >= 0) {
      true => k,
      false => -1,
    });
  }
  if (spec.state == ChartState.ready) {
    _colLabels(spec, labels, gx, gy, cs, tick, font);
    var lastY = double.negativeInfinity;
    for (final r in spec.rowLabels) {
      final y = gy + r.i * cs + cs / 2;
      if (y - lastY < tick * 0.95) continue;
      labels.add(
        ChartLabel(
          id: 'r-${r.i}',
          text: r.text,
          x: gx - 6,
          y: y,
          anchor: LabelAnchor.end,
          valign: LabelValign.middle,
          role: LabelRole.y,
          size: tick,
          tone: LabelTone.muted,
        ),
      );
      lastY = y;
    }
  }
  ({double x, double y, double cell})? legend;
  if (spec.legend case final ends? when spec.state == ChartState.ready) {
    final lc = clampN(cs * 0.9, 10, 16);
    final lw = spec.levelCount * (lc + 3);
    final ly = gy + cs * spec.rows + 8 + lc / 2;
    final lx =
        math.min(gx + cs * spec.cols, w - 4) -
        lw -
        textWidth(ends.more, tick, font) -
        8;
    legend = (x: lx, y: ly - lc / 2, cell: lc);
    labels
      ..add(
        ChartLabel(
          id: 'less',
          text: ends.less,
          x: lx - 6,
          y: ly,
          anchor: LabelAnchor.end,
          valign: LabelValign.middle,
          role: LabelRole.sub,
          size: tick,
          tone: LabelTone.muted,
        ),
      )
      ..add(
        ChartLabel(
          id: 'more',
          text: ends.more,
          x: lx + lw + 6,
          y: ly,
          anchor: LabelAnchor.start,
          valign: LabelValign.middle,
          role: LabelRole.sub,
          size: tick,
          tone: LabelTone.muted,
        ),
      );
  }
  if (spec.state != ChartState.ready) {
    labels.add(
      ChartLabel(
        id: 'state',
        text: stateTextOf(spec.stateText, spec.state == ChartState.loading),
        x: w / 2,
        y: h / 2,
        anchor: LabelAnchor.middle,
        valign: LabelValign.middle,
        role: LabelRole.center,
        size: 20,
        tone: LabelTone.muted,
      ),
    );
  }
  final total = spec.cols * spec.rows;
  final targets = ChartTargets(
    n: total,
    mode: TargetMode.cell,
    cx: [for (var k = 0; k < total; k++) gx + (k % spec.cols) * cs + cs / 2],
    cy: [for (var k = 0; k < total; k++) gy + (k ~/ spec.cols) * cs],
    nav: TargetNav.grid,
    cols: spec.cols,
    cells: CellTargets(
      x0: gx,
      y0: gy,
      cw: cs,
      ch: cs,
      cols: spec.cols,
      rows: spec.rows,
      index: index,
    ),
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= total || i >= index.length || index[i] < 0) {
      return const [];
    }
    return [
      CursorSpec(
        kind: CursorKind.cell,
        x: gx + (i % spec.cols) * cs - 2,
        y: gy + (i ~/ spec.cols) * cs - 2,
        w: cell + 4 + gap,
        h: cell + 4 + gap,
      ),
    ];
  }

  return HeatLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    cs: cs,
    cell: cell,
    gx: gx,
    gy: gy,
    cells: cells,
    legend: legend,
  );
}

void _colLabels(
  HeatSpec spec,
  List<ChartLabel> labels,
  double gx,
  double gy,
  double cs,
  double tick,
  LabelFont font,
) {
  if (spec.variant == HeatVariant.grid) {
    for (final c in spec.colLabels) {
      labels.add(
        ChartLabel(
          id: 'c-${c.i}',
          text: c.text,
          x: gx + c.i * cs + cs / 2,
          y: gy - 6,
          anchor: LabelAnchor.middle,
          valign: LabelValign.bottom,
          role: LabelRole.x,
          size: tick,
          tone: LabelTone.ink,
          maxW: math.max(cs, 24.0),
        ),
      );
    }
    return;
  }
  var free = double.negativeInfinity;
  for (final c in spec.colLabels) {
    final x = gx + c.i * cs;
    if (x < free) continue;
    labels.add(
      ChartLabel(
        id: 'c-${c.i}',
        text: c.text,
        x: x,
        y: gy - 6,
        anchor: LabelAnchor.start,
        valign: LabelValign.bottom,
        role: LabelRole.x,
        size: tick,
        tone: LabelTone.ink,
      ),
    );
    free = x + textWidth(c.text, tick, font) + 6;
  }
}
