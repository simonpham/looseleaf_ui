import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_spec.dart';
import 'package:looseleaf_ink/src/charts/xy_geometry.dart';
import 'package:looseleaf_ink/src/charts/xy_layout.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How an XY series is drawn.
///
/// Mirrors `XYKind` in `src/lib/ink/charts/chart-types.ts`.
enum XYKind { bar, line, area, scatter }

/// How a line joins its points.
enum CurveKind { smooth, linear, step }

/// How an annotation marks its point.
enum NoteShape { loop, underline, none }

/// The axis a reference line crosses.
enum RefAxis { y, x }

/// One XY series, resolved.
///
/// Mirrors `XYSeries` in `src/lib/ink/charts/chart-types.ts`.
final class XYSeries {
  /// A series.
  const XYSeries({
    required this.key,
    required this.name,
    required this.slot,
    required this.kind,
    required this.pattern,
    required this.marker,
    required this.dash,
    required this.values,
    this.xs,
    this.sizes,
  });

  /// The data key.
  final String key;

  /// The display name.
  final String name;

  /// The colour slot.
  final int slot;

  /// How it is drawn.
  final XYKind kind;

  /// Its fill pattern.
  final FillPattern pattern;

  /// Its point marker.
  final MarkerShape marker;

  /// Its line dash.
  final Dash dash;

  /// One value per category (or point); null for a gap.
  final List<double?> values;

  /// Scatter x values (NaN when missing).
  final List<double>? xs;

  /// Scatter bubble sizes (NaN when missing).
  final List<double>? sizes;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
    'slot': slot,
    'kind': kind.name,
    'pattern': pattern.name,
    'marker': marker.name,
    'dash': dash.name,
    'values': values,
    'xs': xs,
    'sizes': sizes,
  };
}

/// A handwritten annotation on point [i] of series [s].
///
/// Mirrors `XYNote` in `src/lib/ink/charts/chart-types.ts`.
final class XYNote {
  /// A note.
  const XYNote({
    required this.s,
    required this.i,
    required this.text,
    required this.pen,
    required this.shape,
    this.dx,
    this.dy,
  });

  /// Series index.
  final int s;

  /// Category index.
  final int i;

  /// The note.
  final String text;

  /// The pen.
  final NotePen pen;

  /// How the point is marked.
  final NoteShape shape;

  /// A pinned label offset, x.
  final double? dx;

  /// A pinned label offset, y.
  final double? dy;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    's': s,
    'i': i,
    'text': text,
    'pen': pen.name,
    'shape': shape.name,
    'dx': dx,
    'dy': dy,
  };
}

/// A shaded category range.
///
/// Mirrors `XYBand` in `src/lib/ink/charts/chart-types.ts`.
final class XYBand {
  /// A band.
  const XYBand({required this.i0, required this.i1, this.text});

  /// First category.
  final int i0;

  /// Last category.
  final int i1;

  /// A label.
  final String? text;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {'i0': i0, 'i1': i1, 'text': text};
}

/// A reference line at [value].
///
/// Mirrors `XYRef` in `src/lib/ink/charts/chart-types.ts`.
final class XYRef {
  /// A reference line.
  const XYRef({
    required this.value,
    required this.axis,
    required this.pen,
    this.label,
  });

  /// Where it crosses.
  final double value;

  /// Which axis it marks.
  final RefAxis axis;

  /// A label.
  final String? label;

  /// The pen.
  final NotePen pen;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'value': value,
    'axis': axis.name,
    'label': label,
    'pen': pen.name,
  };
}

/// An axis tick: value and label.
///
/// Mirrors `AxisTick` in `src/lib/ink/charts/chart-types.ts`.
final class AxisTick {
  /// A tick.
  const AxisTick(this.v, this.label);

  /// The value.
  final double v;

  /// The label.
  final String label;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {'v': v, 'label': label};
}

List<Object?>? _ticks(List<AxisTick>? t) => switch (t) {
  final ticks? => [for (final tick in ticks) tick.toJson()],
  null => null,
};

List<Object?>? _alt(List<List<AxisTick>>? t) => switch (t) {
  final sets? => [for (final s in sets) _ticks(s)],
  null => null,
};

Object _auto(bool? v) => switch (v) {
  final on? => on,
  null => 'auto',
};

/// A bar, line, area or scatter chart, resolved: categories, series,
/// scales, annotations and state.
///
/// Mirrors `XYSpec` in `src/lib/ink/charts/chart-types.ts`.
final class XYSpec extends ChartSpec {
  /// An XY chart.
  const XYSpec({
    required this.cats,
    required this.series,
    required this.stacked,
    required this.horizontal,
    required this.curve,
    required this.yMin,
    required this.yMax,
    required this.yTicks,
    required this.grid,
    required this.showX,
    required this.showY,
    required this.zero,
    required this.notes,
    required this.refs,
    required this.bands,
    required this.patterns,
    required this.state,
    this.yTicksAlt,
    this.xMin,
    this.xMax,
    this.xTicks,
    this.xTicksAlt,
    this.dots,
    this.values,
    this.valueLabels,
    this.stateText,
    this.total,
    this.catEm,
  });

  /// Category labels (empty for scatter).
  final List<String> cats;

  /// The drawn series.
  final List<XYSeries> series;

  /// Whether bars and areas stack.
  final bool stacked;

  /// Whether bars run sideways.
  final bool horizontal;

  /// How lines join points.
  final CurveKind curve;

  /// Value axis low end.
  final double yMin;

  /// Value axis high end.
  final double yMax;

  /// Value ticks.
  final List<AxisTick> yTicks;

  /// Sparser value tick sets, for small charts.
  final List<List<AxisTick>>? yTicksAlt;

  /// Scatter x low end.
  final double? xMin;

  /// Scatter x high end.
  final double? xMax;

  /// Scatter x ticks.
  final List<AxisTick>? xTicks;

  /// Sparser scatter x tick sets.
  final List<List<AxisTick>>? xTicksAlt;

  /// Point dots: on, off, or null for auto.
  final bool? dots;

  /// Bar value labels: on, off, or null for auto.
  final bool? values;

  /// Value label text per series and category.
  final List<List<String?>>? valueLabels;

  /// Whether to draw gridlines.
  final bool grid;

  /// Whether to show the category axis.
  final bool showX;

  /// Whether to show the value axis.
  final bool showY;

  /// Whether the value axis includes zero.
  final bool zero;

  /// Annotations.
  final List<XYNote> notes;

  /// Reference lines.
  final List<XYRef> refs;

  /// Shaded ranges.
  final List<XYBand> bands;

  /// Whether fills use patterns.
  final bool patterns;

  /// Data state.
  final ChartState state;

  /// Text shown for an empty or loading chart.
  final String? stateText;

  /// The row count before thinning, when rows were thinned.
  final int? total;

  /// The widest category label measured in the real face, in ems. A
  /// sideways chart gives its category axis this much room instead of the
  /// [textWidth] estimate; null keeps the estimate, like upstream.
  final double? catEm;

  /// This spec with [catEm] measured.
  XYSpec withCatEm(double? catEm) => XYSpec(
    cats: cats,
    series: series,
    stacked: stacked,
    horizontal: horizontal,
    curve: curve,
    yMin: yMin,
    yMax: yMax,
    yTicks: yTicks,
    grid: grid,
    showX: showX,
    showY: showY,
    zero: zero,
    notes: notes,
    refs: refs,
    bands: bands,
    patterns: patterns,
    state: state,
    yTicksAlt: yTicksAlt,
    xMin: xMin,
    xMax: xMax,
    xTicks: xTicks,
    xTicksAlt: xTicksAlt,
    dots: dots,
    values: values,
    valueLabels: valueLabels,
    stateText: stateText,
    total: total,
    catEm: catEm,
  );

  @override
  XYLayout layout(Box box, [bool calm = false]) => layoutXY(this, box, calm);

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'type': 'xy',
    'cats': cats,
    'series': [for (final s in series) s.toJson()],
    'stacked': stacked,
    'horizontal': horizontal,
    'curve': curve.name,
    'yMin': yMin,
    'yMax': yMax,
    'yTicks': _ticks(yTicks),
    'yTicksAlt': _alt(yTicksAlt),
    'xMin': xMin,
    'xMax': xMax,
    'xTicks': _ticks(xTicks),
    'xTicksAlt': _alt(xTicksAlt),
    'dots': _auto(dots),
    'values': _auto(values),
    'valueLabels': valueLabels,
    'grid': grid,
    'showX': showX,
    'showY': showY,
    'zero': zero,
    'notes': [for (final n in notes) n.toJson()],
    'refs': [for (final r in refs) r.toJson()],
    'bands': [for (final b in bands) b.toJson()],
    'patterns': patterns,
    'state': state.name,
    'stateText': stateText,
    'total': total,
    'catEm': ?catEm,
  };
}
