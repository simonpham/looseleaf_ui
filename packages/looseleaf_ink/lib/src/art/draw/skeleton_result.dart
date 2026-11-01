import 'package:looseleaf_ink/src/art/draw/silhouette.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';

/// Drawn art: the [result] markup and how it was drawn.
///
/// Mirrors `SkeletonResult` in `src/lib/ink/art-draw.ts`.
class SkeletonResult {
  /// A result.
  const SkeletonResult({
    required this.result,
    required this.variant,
    required this.kind,
    required this.nib,
    required this.k,
    required this.silhouette,
  });

  /// The markup.
  final InkResult result;

  /// The variant drawn.
  final Variant variant;

  /// The kind drawn.
  final ArtKind kind;

  /// The nib width.
  final double nib;

  /// Pixels per grid unit.
  final double k;

  /// The silhouette.
  final Silhouette silhouette;

  /// The markup of every layer.
  String get svg => result.svg;
}

/// A die-cut sticker: the art on a white border, offset by [off].
///
/// Mirrors `DieCutResult` in `src/lib/ink/art-draw.ts`.
final class DieCutResult extends SkeletonResult {
  /// A result.
  const DieCutResult({
    required super.result,
    required super.variant,
    required super.kind,
    required super.nib,
    required super.k,
    required super.silhouette,
    required this.off,
    required this.border,
  });

  /// The art's offset inside the sticker.
  final double off;

  /// The border width.
  final double border;
}
