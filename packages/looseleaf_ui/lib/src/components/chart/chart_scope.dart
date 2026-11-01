import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// What a [ChartContainer] gives the chart, legend and tooltip inside it.
///
/// Mirrors `ChartContext` in upstream `src/components/ui/chart.tsx`.
class ChartScope extends InheritedWidget {
  const ChartScope({
    super.key,
    required this.config,
    required this.hidden,
    required this.toggle,
    required this.patterns,
    required this.controller,
    required this.legend,
    required super.child,
    this.tooltip,
  });

  /// The series config.
  final ChartConfig config;

  /// The series switched off.
  final Set<String> hidden;

  /// Switches a series off or back on.
  final ValueChanged<String> toggle;

  /// Whether series get patterns.
  final ChartPatterns patterns;

  /// The shared cursor state.
  final ChartController controller;

  /// The entries the chart registered for its legend.
  final List<ChartLegendEntry> legend;

  /// The tooltip settings, when the container holds a [ChartTooltip].
  final ChartTooltip? tooltip;

  /// The config keys in order: a key's index is its palette slot.
  List<String> get keys => [...config.keys];

  /// The nearest scope, or null outside a [ChartContainer].
  static ChartScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChartScope>();

  /// The nearest scope.
  static ChartScope of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError('Chart parts must be inside a ChartContainer.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(ChartScope oldWidget) =>
      !identical(oldWidget.config, config) ||
      !setEquals(oldWidget.hidden, hidden) ||
      oldWidget.patterns != patterns ||
      oldWidget.controller != controller ||
      !identical(oldWidget.legend, legend) ||
      oldWidget.tooltip != tooltip;
}
