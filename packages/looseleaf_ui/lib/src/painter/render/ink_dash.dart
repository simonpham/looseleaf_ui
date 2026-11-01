import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/markup.dart';

/// `stroke-dasharray`: cuts a shape's outline into dashes, honoring
/// `pathLength` and `stroke-dashoffset`. Results are cached on the node.
abstract final class InkDash {
  static Path dashed(InkShapeNode node, List<double> dashes, double offset) {
    final key = '${dashes.join(' ')}|$offset';
    return node.dashCache[key] ??= _dash(node, dashes, offset);
  }

  /// [node]'s outline drawn on up to [fraction]: `stroke-dasharray: 1` (or
  /// [dashes]) with `stroke-dashoffset` animating from 1 to 0, upstream's
  /// `ll-draw`. Not cached, since it changes every animation frame.
  static Path revealed(
    InkShapeNode node,
    double fraction, {
    List<double>? dashes,
  }) => _dash(node, dashes ?? const [1, 1], 1 - fraction.clamp(0.0, 1.0));

  static Path _dash(InkShapeNode node, List<double> dashes, double offset) {
    final metrics = node.path.computeMetrics().toList();
    final total = metrics.fold(0.0, (sum, metric) => sum + metric.length);
    final scale = switch (node.pathLength) {
      final length? when length > 0 => total / length,
      _ => 1.0,
    };
    final pattern = [for (final dash in dashes) dash * scale];
    final period = pattern.fold(0.0, (sum, dash) => sum + dash);
    final out = Path();
    if (period <= 0) return node.path;
    for (final metric in metrics) {
      var index = 0;
      var phase = (offset * scale) % period;
      while (phase >= pattern[index]) {
        phase -= pattern[index];
        index = (index + 1) % pattern.length;
      }
      var distance = -phase;
      while (distance < metric.length) {
        final end = distance + pattern[index];
        if (index.isEven && end > 0) {
          out.addPath(
            metric.extractPath(
              distance.clamp(0, metric.length),
              end.clamp(0, metric.length),
            ),
            Offset.zero,
          );
        }
        distance = end;
        index = (index + 1) % pattern.length;
      }
    }
    return out;
  }
}
