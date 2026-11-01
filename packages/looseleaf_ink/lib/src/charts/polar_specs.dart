import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_spec.dart';
import 'package:looseleaf_ink/src/charts/gauge_layout.dart';
import 'package:looseleaf_ink/src/charts/pie_layout.dart';
import 'package:looseleaf_ink/src/charts/radar_layout.dart';
import 'package:looseleaf_ink/src/charts/radial_layout.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A pie slice.
///
/// Mirrors `Slice` in `src/lib/ink/charts/chart-types.ts`.
final class Slice {
  /// A slice.
  const Slice({
    required this.key,
    required this.name,
    required this.slot,
    required this.pattern,
    required this.value,
    this.label,
  });

  /// The data key.
  final String key;

  /// The display name.
  final String name;

  /// The colour slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The value; non-positive values get no sector.
  final double value;

  /// The outside label; defaults to its share.
  final String? label;

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
    'slot': slot,
    'pattern': pattern.name,
    'value': value,
    'label': ?label,
  };
}

/// A pie or donut chart.
///
/// Mirrors `PieSpec` in `src/lib/ink/charts/chart-types.ts`.
final class PieSpec extends ChartSpec {
  /// A pie.
  const PieSpec({
    required this.slices,
    required this.inner,
    required this.start,
    required this.labels,
    required this.patterns,
    required this.state,
    this.stateText,
  });

  /// The slices.
  final List<Slice> slices;

  /// The hole, as a fraction of the radius (0 for a pie).
  final double inner;

  /// Start angle in degrees, clockwise from 12 o'clock.
  final double start;

  /// Whether to label slices.
  final bool labels;

  /// Whether fills use patterns.
  final bool patterns;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  PieLayout layout(Box box, [bool calm = false]) => layoutPie(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'pie',
    'slices': [for (final s in slices) s.toJson()],
    'inner': inner,
    'start': start,
    'labels': labels,
    'patterns': patterns,
    'state': state.name,
    'stateText': ?stateText,
  };
}

/// One radar series.
///
/// Mirrors `RadarSeries` in `src/lib/ink/charts/chart-types.ts`.
final class RadarSeries {
  /// A series.
  const RadarSeries({
    required this.key,
    required this.name,
    required this.slot,
    required this.pattern,
    required this.marker,
    required this.values,
  });

  /// The data key.
  final String key;

  /// The display name.
  final String name;

  /// The colour slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The point marker.
  final MarkerShape marker;

  /// One value per axis; null for a gap.
  final List<double?> values;

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
    'slot': slot,
    'pattern': pattern.name,
    'marker': marker.name,
    'values': values,
  };
}

/// A radar (spider) chart.
///
/// Mirrors `RadarSpec` in `src/lib/ink/charts/chart-types.ts`.
final class RadarSpec extends ChartSpec {
  /// A radar.
  const RadarSpec({
    required this.axes,
    required this.series,
    required this.max,
    required this.levels,
    required this.ringLabels,
    required this.fill,
    required this.patterns,
    required this.dots,
    required this.state,
    this.stateText,
  });

  /// Axis names, clockwise from the top.
  final List<String> axes;

  /// The series.
  final List<RadarSeries> series;

  /// The value at the rim.
  final double max;

  /// How many rings.
  final double levels;

  /// Ring labels, outermost first.
  final List<String> ringLabels;

  /// Whether to fill the polygons.
  final bool fill;

  /// Whether fills use patterns.
  final bool patterns;

  /// Whether to dot the points.
  final bool dots;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  RadarLayout layout(Box box, [bool calm = false]) =>
      layoutRadar(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'radar',
    'axes': axes,
    'series': [for (final s in series) s.toJson()],
    'max': max,
    'levels': levels,
    'ringLabels': ringLabels,
    'fill': fill,
    'patterns': patterns,
    'dots': dots,
    'state': state.name,
    'stateText': ?stateText,
  };
}

/// One radial bar.
///
/// Mirrors `RadialRing` in `src/lib/ink/charts/chart-types.ts`.
final class RadialRing {
  /// A ring.
  const RadialRing({
    required this.key,
    required this.name,
    required this.slot,
    required this.pattern,
    required this.value,
    required this.max,
    this.label,
  });

  /// The data key.
  final String key;

  /// The display name.
  final String name;

  /// The colour slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The value.
  final double value;

  /// The value of a full ring.
  final double max;

  /// A value label.
  final String? label;

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
    'slot': slot,
    'pattern': pattern.name,
    'value': value,
    'max': max,
    'label': ?label,
  };
}

/// A radial bar chart: concentric arcs.
///
/// Mirrors `RadialSpec` in `src/lib/ink/charts/chart-types.ts`.
final class RadialSpec extends ChartSpec {
  /// A radial chart.
  const RadialSpec({
    required this.rings,
    required this.start,
    required this.end,
    required this.patterns,
    required this.state,
    this.stateText,
  });

  /// The rings, outermost first.
  final List<RadialRing> rings;

  /// Start angle in degrees.
  final double start;

  /// End angle of a full ring, in degrees.
  final double end;

  /// Whether fills use patterns.
  final bool patterns;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  RadialLayout layout(Box box, [bool calm = false]) =>
      layoutRadial(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'radial',
    'rings': [for (final r in rings) r.toJson()],
    'start': start,
    'end': end,
    'patterns': patterns,
    'state': state.name,
    'stateText': ?stateText,
  };
}

/// A coloured gauge zone up to [to].
///
/// Mirrors `GaugeZone` in `src/lib/ink/charts/chart-types.ts`.
final class GaugeZone {
  /// A zone.
  const GaugeZone({
    required this.to,
    required this.slot,
    required this.pattern,
  });

  /// Where it ends.
  final double to;

  /// The colour slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'to': to,
    'slot': slot,
    'pattern': pattern.name,
  };
}

/// A gauge (speedometer) chart.
///
/// Mirrors `GaugeSpec` in `src/lib/ink/charts/chart-types.ts`.
final class GaugeSpec extends ChartSpec {
  /// A gauge.
  const GaugeSpec({
    required this.value,
    required this.min,
    required this.max,
    required this.zones,
    required this.sweep,
    required this.ticks,
    required this.minLabel,
    required this.maxLabel,
    required this.patterns,
    required this.state,
    this.stateText,
  });

  /// The needle value.
  final double value;

  /// The low end.
  final double min;

  /// The high end.
  final double max;

  /// Coloured zones, low to high.
  final List<GaugeZone> zones;

  /// The arc's sweep in degrees.
  final double sweep;

  /// How many tick intervals.
  final double ticks;

  /// The low end label.
  final String minLabel;

  /// The high end label.
  final String maxLabel;

  /// Whether fills use patterns.
  final bool patterns;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  GaugeLayout layout(Box box, [bool calm = false]) =>
      layoutGauge(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'gauge',
    'value': value,
    'min': min,
    'max': max,
    'zones': [for (final z in zones) z.toJson()],
    'sweep': sweep,
    'ticks': ticks,
    'minLabel': minLabel,
    'maxLabel': maxLabel,
    'patterns': patterns,
    'state': state.name,
    'stateText': ?stateText,
  };
}
