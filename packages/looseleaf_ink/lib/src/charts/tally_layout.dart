import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/mini_specs.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A tally row's geometry: gates from [x] to [right], [marks] long.
///
/// Mirrors `TallyRowGeom` in `src/lib/ink/charts/chart-mini.ts`.
final class TallyRowGeom {
  /// A row.
  const TallyRowGeom({
    required this.index,
    required this.y,
    required this.gh,
    required this.x,
    required this.marks,
    required this.right,
  });

  /// The row index.
  final int index;

  /// Gate top.
  final double y;

  /// Gate height.
  final double gh;

  /// Gates start.
  final double x;

  /// How many marks.
  final int marks;

  /// Gates end.
  final double right;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'index': index,
    'y': y,
    'gh': gh,
    'x': x,
    'marks': marks,
    'right': right,
  };
}

/// A laid out tally chart.
///
/// Mirrors `TallyLayout` in `src/lib/ink/charts/chart-mini.ts`.
final class TallyLayout extends ChartLayoutBase {
  /// A layout.
  const TallyLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.rows,
    required this.unit,
    required this.markArea,
  });

  /// The rows.
  final List<TallyRowGeom> rows;

  /// What one mark counts.
  final double unit;

  /// Where the gates may go.
  final ({double x0, double x1}) markArea;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'rows': [for (final r in rows) r.toJson()],
    'unit': unit,
    'markArea': {'x0': markArea.x0, 'x1': markArea.x1},
  };
}

/// The most marks a tally draws per row (`MAX_MARKS`).
const int maxMarks = 250;

const List<double> _units = [
  1,
  2,
  5,
  10,
  20,
  25,
  50,
  100,
  200,
  250,
  500,
  1000,
  2000,
  5000,
  10000,
  100000,
];

double _count(double v) => switch (v.isFinite) {
  true => v,
  false => 0,
};

/// Lays out a tally chart in [box].
///
/// Mirrors `layoutTally` in `src/lib/ink/charts/chart-mini.ts`.
TallyLayout layoutTally(TallySpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final font = switch (calm) {
    true => LabelFont.hand,
    false => LabelFont.script,
  };
  final tick = switch ((calm, bucket)) {
    (true, _) => 13.0,
    (false, Bucket.sm) => 15.0,
    _ => 17.0,
  };
  final labels = <ChartLabel>[];
  final m = spec.rows.length;
  final nameW = math.min(
    w * 0.34,
    spec.rows.fold(0.0, (b, r) => math.max(b, textWidth(r.name, tick, font))) +
        4,
  );
  final totalW =
      spec.totals.fold(0.0, (b, t) => math.max(b, textWidth(t, tick, font))) +
      6;
  final x0 = nameW + 14;
  final x1 = w - totalW - 10;
  final rh = switch (m) {
    0 => 40.0,
    _ => clampN((h - 8) / m, 24, 52),
  };
  final gh = clampN(rh * 0.62, 14, 28);
  final maxCount = spec.rows.fold(1.0, (b, r) => math.max(b, _count(r.count)));
  double groupW(double g) => 1.05 * g + 6;
  bool fits(double unit) =>
      (maxCount / unit / 5).ceil() * groupW(gh) - 6 <= x1 - x0;
  final need = (maxCount / maxMarks).ceilToDouble();
  final floor = _units.firstWhere((u) => u >= need, orElse: () => need);
  final unit = math.max(
    floor,
    switch (spec.unit > 0) {
      true => spec.unit,
      false => _units.firstWhere(fits, orElse: () => _units.last),
    },
  );
  final usedH = m * rh;
  final top = math.max(4.0, math.min(12.0, (h - usedH) / 2));
  final rows = <TallyRowGeom>[];
  for (final (i, r) in spec.rows.indexed) {
    final marks = (_count(r.count) / unit).ceil();
    final groups = (marks / 5).ceil();
    final y = top + i * rh + (rh - gh) / 2;
    final partial = marks % 5;
    final short = switch (partial) {
      0 => 0.0,
      _ => (5 - partial) * 0.26 * gh,
    };
    final right = x0 + math.max(0.0, groups * groupW(gh) - 6 - short);
    labels
      ..add(
        ChartLabel(
          id: 'n-$i',
          text: r.name,
          x: 4,
          y: y + gh / 2,
          anchor: LabelAnchor.start,
          valign: LabelValign.middle,
          role: LabelRole.cat,
          size: tick,
          tone: LabelTone.ink,
          maxW: nameW,
        ),
      )
      ..add(
        ChartLabel(
          id: 't-$i',
          text:
              spec.totals.elementAtOrNull(i) ?? JsMath.numberToString(r.count),
          x: w - 4,
          y: y + gh / 2,
          anchor: LabelAnchor.end,
          valign: LabelValign.middle,
          role: LabelRole.value,
          size: tick,
          tone: LabelTone.muted,
        ),
      );
    rows.add(
      TallyRowGeom(index: i, y: y, gh: gh, x: x0, marks: marks, right: right),
    );
  }
  if (unit > 1 && spec.state == ChartState.ready) {
    labels.add(
      ChartLabel(
        id: 'unit',
        text: 'each mark = ${JsMath.numberToString(unit)}',
        x: w - 4,
        y: h - 2,
        anchor: LabelAnchor.end,
        valign: LabelValign.bottom,
        role: LabelRole.sub,
        size: math.max(12.0, tick - 3),
        tone: LabelTone.muted,
      ),
    );
  }
  if (spec.state != ChartState.ready || m == 0) {
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
  final mids = [for (final r in rows) r.y + r.gh / 2];
  final targets = ChartTargets(
    n: m,
    mode: TargetMode.y,
    pos: mids,
    cx: [for (final r in rows) (r.right + x0) / 2],
    cy: mids,
    nav: TargetNav.linear,
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= rows.length) return const [];
    final r = rows[i];
    return [
      CursorSpec(
        kind: CursorKind.column,
        x: 0,
        y: r.y - (rh - r.gh) / 2,
        w: w,
        h: rh,
      ),
    ];
  }

  return TallyLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    rows: rows,
    unit: unit,
    markArea: (x0: x0, x1: x1),
  );
}
