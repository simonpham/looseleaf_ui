import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The chip of a legend or tooltip row: the series' marker fill and pencil
/// pattern in a tiny felt box, or with [line] a line sample with its
/// [marker].
///
/// Mirrors `ChartSwatch` in upstream `src/components/ui/chart.tsx`.
class ChartSwatch extends StatelessWidget {
  const ChartSwatch({
    super.key,
    required this.palette,
    this.pattern = FillPattern.solid,
    this.marker,
    this.line = false,
    this.height,
  });

  /// The series' palette slot.
  final int palette;

  /// The pencil pattern.
  final FillPattern pattern;

  /// The marker on a line sample.
  final MarkerShape? marker;

  /// A line sample instead of a filled chip.
  final bool line;

  /// A height other than 14 px, for the tooltip's bar indicator.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final params = MiniSwatch(
      slot: palette,
      pattern: pattern,
      marker: marker,
      line: line,
    );
    final markerId = marker?.name ?? 'x';
    final shape = switch (line) {
      true => 'l',
      false => 'b',
    };
    return ExcludeSemantics(
      child: SizedBox(
        width: switch (line) {
          true => Spacing.d22,
          false => Spacing.d14,
        },
        height: height ?? Spacing.d14,
        child: InkSurface(
          source: RecipeInkSource(
            chartMarkRecipe,
            params,
            json: params.toJson(),
          ),
          seed: 'swatch-$palette-${pattern.name}-$markerId-$shape',
        ),
      ),
    );
  }
}
