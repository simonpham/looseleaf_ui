import 'package:looseleaf_ink/src/charts/chart_data.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/format.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';

/// A data row: field name to value.
///
/// Mirrors `Row` in `src/lib/ink/charts/chart-build.ts`.
typedef Row = Map<String, Object?>;

/// A series to draw from the rows' [key] field; null looks are automatic.
///
/// Mirrors `SeriesInput` in `src/lib/ink/charts/chart-build.ts`.
final class SeriesInput {
  /// A series.
  const SeriesInput(
    this.key, {
    this.name,
    this.kind,
    this.slot,
    this.pattern,
    this.marker,
    this.dash,
  });

  /// The field.
  final String key;

  /// The display name (defaults to [key]).
  final String? name;

  /// How it is drawn (defaults to the chart's kind).
  final XYKind? kind;

  /// The colour slot (defaults to its index).
  final int? slot;

  /// Its fill pattern, or null for auto.
  final FillPattern? pattern;

  /// Its marker, or null for auto.
  final MarkerShape? marker;

  /// Its dash, or null for auto.
  final Dash? dash;
}

/// An annotation request: [at] is `'max'`, `'min'`, `'first'`, `'last'`,
/// a category index (int) or a category name; [series] a key or index.
///
/// Mirrors `NoteInput` in `src/lib/ink/charts/chart-build.ts`.
final class NoteInput {
  /// A note.
  const NoteInput({
    required this.at,
    required this.text,
    this.series,
    this.pen,
    this.shape,
    this.dx,
    this.dy,
  });

  /// Where it points.
  final Object at;

  /// The series key (String) or index (int); the first when null.
  final Object? series;

  /// The note.
  final String text;

  /// The pen (red by default).
  final NotePen? pen;

  /// How the point is marked (loop by default).
  final NoteShape? shape;

  /// A pinned label offset, x.
  final double? dx;

  /// A pinned label offset, y.
  final double? dy;
}

/// A shaded range between categories (names or indices).
///
/// Mirrors `BandInput` in `src/lib/ink/charts/chart-build.ts`.
final class BandInput {
  /// A band.
  const BandInput({required this.from, required this.to, this.text});

  /// First category: name (String) or index (int).
  final Object from;

  /// Last category: name or index.
  final Object to;

  /// A label.
  final String? text;
}

/// A reference line at [y] (or, on scatter, [x]).
///
/// Mirrors `RefInput` in `src/lib/ink/charts/chart-build.ts`.
final class RefInput {
  /// A reference line.
  const RefInput({this.y, this.x, this.label, this.pen});

  /// Value axis position.
  final double? y;

  /// Scatter x position.
  final double? x;

  /// A label.
  final String? label;

  /// The pen (red by default).
  final NotePen? pen;
}

/// Formats a category value at [index].
typedef CategoryFormat = String Function(Object? v, int index);

/// Everything `buildXY` needs: rows, the category field, series and
/// options. Null options take upstream's defaults.
///
/// Mirrors `XYBuildInput` in `src/lib/ink/charts/chart-build.ts`.
final class XYBuildInput {
  /// An XY chart request.
  const XYBuildInput({
    required this.rows,
    required this.xKey,
    required this.series,
    required this.kind,
    this.stacked,
    this.horizontal,
    this.curve,
    this.domain,
    this.xDomain,
    this.zero,
    this.tickCount,
    this.yFormat,
    this.xFormat,
    this.valueFormat,
    this.dots,
    this.values,
    this.grid,
    this.showX,
    this.showY,
    this.notes = const [],
    this.refs = const [],
    this.bands = const [],
    this.patterns,
    this.hidden = const {},
    this.state,
    this.stateText,
    this.sizeKey,
  });

  /// The data.
  final List<Row> rows;

  /// The category (or scatter x) field.
  final String xKey;

  /// The series.
  final List<SeriesInput> series;

  /// The default series kind.
  final XYKind kind;

  /// Stack bars and areas.
  final bool? stacked;

  /// Sideways bars.
  final bool? horizontal;

  /// Line curve (smooth by default).
  final CurveKind? curve;

  /// Value axis pins.
  final AxisDomain? domain;

  /// Scatter x axis pins.
  final AxisDomain? xDomain;

  /// Include zero (default: when bars or areas are drawn).
  final bool? zero;

  /// About how many value ticks (5).
  final int? tickCount;

  /// Value tick format.
  final ValueFormat? yFormat;

  /// Category (or scatter x) format.
  final CategoryFormat? xFormat;

  /// Bar value label format.
  final ValueFormat? valueFormat;

  /// Point dots: on, off, or null for auto.
  final bool? dots;

  /// Bar value labels: on, off, or null for auto.
  final bool? values;

  /// Gridlines (on).
  final bool? grid;

  /// Category axis (on).
  final bool? showX;

  /// Value axis (on).
  final bool? showY;

  /// Annotations.
  final List<NoteInput> notes;

  /// Reference lines.
  final List<RefInput> refs;

  /// Shaded ranges.
  final List<BandInput> bands;

  /// Patterns: on, off, or null for auto.
  final bool? patterns;

  /// Series keys to leave out.
  final Set<String> hidden;

  /// Data state (derived when null).
  final ChartState? state;

  /// Text for an empty or loading chart.
  final String? stateText;

  /// Scatter bubble size field.
  final String? sizeKey;
}
