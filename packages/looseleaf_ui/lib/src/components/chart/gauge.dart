import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A gauge zone's color: a named tone or a palette slot.
enum GaugeTone {
  good(2),
  warn(3),
  bad(5),
  info(1),
  brand(0);

  const GaugeTone(this.slot);

  /// The palette slot.
  final int slot;
}

/// A colored stretch of a [Gauge], from the previous zone up [to] a value.
class GaugeZoneInput {
  const GaugeZoneInput({required this.to, this.tone, this.slot});

  /// Where the zone ends.
  final double to;

  /// Its tone; good, warn, bad in turn when neither this nor [slot] is set.
  final GaugeTone? tone;

  /// A palette slot instead of a [tone].
  final int? slot;
}

/// A dial: marker zones (each with a pencil pattern) and a red felt
/// needle, or a single colored arc. Screen readers hear a meter with its
/// value, ends and words; [child] is the text under the pivot (the value
/// by default).
///
/// Mirrors `Gauge` in upstream `src/components/ui/chart.tsx`.
class Gauge extends ChartWidget {
  const Gauge({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.zones = const [],
    this.sweep = 180,
    this.ticks = 10,
    this.valueFormatter,
    this.child,
    super.config,
    super.label,
    super.description,
    super.loading,
    super.animate,
    super.seed,
  }) : super(tooltip: false);

  /// The reading; clamped to [min] and [max].
  final double value;

  /// The start of the dial.
  final double min;

  /// The end of the dial.
  final double max;

  /// Colored stretches from [min] up.
  final List<GaugeZoneInput> zones;

  /// Degrees the dial covers.
  final double sweep;

  /// Pencil ticks round the outside.
  final double ticks;

  /// Number text.
  final ChartValueFormatter? valueFormatter;

  /// The text under the pivot.
  final Widget? child;

  static const List<GaugeTone> _cycle = [
    GaugeTone.good,
    GaugeTone.warn,
    GaugeTone.bad,
  ];

  @override
  ChartConfig autoConfig() => const {};

  @override
  bool get legendByDefault => false;

  @override
  double get standaloneAspectRatio => 2;

  @override
  double get standaloneMaxWidth => 448;

  @override
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  ) => const [];

  @override
  Widget buildChart(BuildContext context, ChartScope scope) {
    final reading = switch (value.isFinite) {
      true => value,
      false => min,
    };
    final format = valueFormatter ?? formatNumber;
    final spec = GaugeSpec(
      value: reading,
      min: min,
      max: max,
      zones: [
        for (final (k, z) in zones.indexed)
          GaugeZone(
            to: z.to,
            slot: z.slot ?? (z.tone ?? _cycle[k % _cycle.length]).slot,
            pattern: defaultPattern(k),
          ),
      ],
      sweep: sweep,
      ticks: ticks,
      minLabel: format(min),
      maxLabel: format(max),
      patterns: scope.patterns != ChartPatterns.off,
      state: switch (loading) {
        true => ChartState.loading,
        false => ChartState.ready,
      },
    );
    final zone = [
      for (final z in zones)
        if (reading <= z.to) z,
    ].firstOrNull;
    final tone = switch (zone?.tone) {
      final t? => ', ${t.name}',
      null => '',
    };
    final title = switch (label) {
      final l? => '$l. ',
      null => '',
    };
    final extra = switch (description) {
      final d? => ' $d',
      null => '',
    };
    return ChartCanvas<GaugeSpec>(
      recipe: chartGaugeRecipe,
      spec: spec,
      specJson: spec.toJson(),
      state: spec.state,
      label: label ?? 'Gauge',
      summary:
          '${title}Gauge reading ${format(reading)} on a scale from ${format(min)} to ${format(max)}.$extra',
      table: TableModel(
        head: const ['Reading', 'Minimum', 'Maximum'],
        rows: [
          [format(reading), format(min), format(max)],
        ],
      ),
      describe: (_, _, _) => null,
      interactive: false,
      animate: animate,
      seed: seed,
      meter: ChartMeter(
        min: min,
        max: max,
        now: math.max(min, math.min(max, reading)),
        text: '${format(reading)} of ${format(max)}$tone',
      ),
      overlay: (context, layout, _) {
        final g = layoutGauge(spec, Box(layout.w, layout.h));
        final drop = switch (sweep <= 180) {
          true => Spacing.d26,
          false => Spacing.d14,
        };
        return ChartAtPoint(
          x: g.cx,
          y: g.cy + drop,
          child: child ?? ChartCenterLabel(value: format(reading)),
        );
      },
    );
  }
}
