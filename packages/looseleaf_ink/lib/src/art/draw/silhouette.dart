import 'package:looseleaf_ink/src/core/core.dart';

/// The outline of drawn art for its die cut: smoothed fill outlines, open
/// stroke paths, sample points (for the peel) and the nib width [w].
///
/// Mirrors `Silhouette` in `src/lib/ink/art-draw.ts`.
final class Silhouette {
  /// A silhouette for a nib of [w] pixels.
  Silhouette(this.w);

  /// Closed fill outlines.
  final List<String> fills = [];

  /// Open stroke paths.
  final List<String> lines = [];

  /// Sample points.
  final List<Pt> pts = [];

  /// The nib width.
  final double w;
}
