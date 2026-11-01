import 'package:looseleaf_ink/src/core/core.dart';

/// A finished drawing: the markup per layer and the padding it needs.
///
/// Mirrors `InkResult` in `src/lib/ink/builder.ts`.
final class InkResult {
  /// A result.
  const InkResult({
    required this.svg,
    required this.w,
    required this.h,
    required this.pad,
    required this.layers,
    required this.parts,
    required this.bbox,
  });

  /// One layer's markup, or every layer wrapped in `<g data-layer>`.
  final String svg;
  final double w;
  final double h;

  /// Padding around the box so nothing is clipped.
  final double pad;

  /// The emitted layers, in drawing order.
  final List<LayerName> layers;

  /// The markup per layer.
  final Map<LayerName, String> parts;
  final BBox bbox;
}

/// The SVG `viewBox` for a result: the box grown by its padding.
///
/// Mirrors `inkViewBox` in `src/lib/ink/builder.ts`.
String inkViewBox({
  required double w,
  required double h,
  required double pad,
}) => '${n(-pad)} ${n(-pad)} ${n(w + 2 * pad)} ${n(h + 2 * pad)}';
