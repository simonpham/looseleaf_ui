import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// One entry of a [ChartConfig]: how a series (or a slice) is named and
/// drawn.
///
/// Mirrors an entry of `ChartConfig` in upstream
/// `src/components/ui/chart.tsx`.
class ChartSeriesConfig {
  const ChartSeriesConfig({
    this.label,
    this.icon,
    this.color,
    this.pattern,
    this.marker,
    this.dash,
  });

  /// The name in the legend, the tooltip and the summary; the key when null.
  final String? label;

  /// Shown instead of the swatch in the legend and the tooltip.
  final Widget? icon;

  /// The series color; the palette slot of its position when null.
  final Color? color;

  /// The pencil pattern on filled marks; automatic when null.
  final FillPattern? pattern;

  /// The point marker; automatic when null.
  final MarkerShape? marker;

  /// The line dash; automatic when null.
  final Dash? dash;
}

/// The series of a chart, by data key, in palette order: a key's position
/// is its color slot (marker orange, blue felt, green pencil, deep
/// highlighter, grape, …).
typedef ChartConfig = Map<String, ChartSeriesConfig>;

/// Whether series get pencil patterns, markers and dashes besides color.
enum ChartPatterns {
  /// Solid color only.
  off,

  /// Patterns when more than one series is drawn.
  auto,

  /// Patterns always.
  on;

  /// The engine's `patterns` option: false, null (auto) or true.
  bool? get look => switch (this) {
    ChartPatterns.off => false,
    ChartPatterns.auto => null,
    ChartPatterns.on => true,
  };
}

/// Where a self-contained chart puts its legend.
enum ChartLegendPlacement {
  /// No legend.
  none,

  /// Above the drawing.
  top,

  /// Below the drawing.
  bottom,
}

/// A chart annotation: a hand-circled call-out (upstream `ChartAnnotation`).
typedef ChartAnnotation = NoteInput;

/// A stretch of categories marked with a highlighter (upstream
/// `ChartHighlight`).
typedef ChartHighlight = BandInput;

/// A dashed goal line (upstream `ChartReference`).
typedef ChartReference = RefInput;

/// A data point picked by the pointer or the keys: its target [index] and,
/// on multi-series charts, the [series] the keys narrowed to.
typedef ChartPoint = ({int index, int? series});

/// Formats a number for axes, values, tooltips and summaries.
typedef ChartValueFormatter = String Function(double value);

/// Which side of the chart a legend sits on (upstream `verticalAlign`).
enum ChartLegendAlign { top, bottom }
