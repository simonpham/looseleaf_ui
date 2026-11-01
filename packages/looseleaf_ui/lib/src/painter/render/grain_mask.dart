import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/markup.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';

/// Looseleaf's grain masks (`ll-felt-0` … `ll-stamp-5`), the global defs of
/// `svgMaskDefs` in `src/lib/ink/textures.ts`: a luminance mask filled with a
/// tiled grain bitmap, phase-shifted and rotated per variant.
abstract final class GrainMask {
  static final RegExp _id = RegExp(r'^ll-([a-z]+)(?:-(\d+))?$');

  /// Turns luminance into alpha, as an SVG luminance mask does (sRGB).
  static const ColorFilter luminanceToAlpha = ColorFilter.matrix([
    0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0.2125, 0.7154, 0.0721, 0, 0,
  ]);

  /// The grain kind and variant of a mask id, or null when it is not one.
  static (String, int)? parse(String id) {
    final match = _id.firstMatch(id);
    if (match == null) return null;
    final kind = match[1] ?? '';
    if (InkTextures.grainTile(kind) == null) return null;
    final variant = int.tryParse(match[2] ?? '0') ?? 0;
    return (kind, variant % 6);
  }

  /// The pattern transform of a variant, like upstream `grainPhase`.
  static InkAffine phase(int variant, double tile) {
    const rotations = [0.0, 90.0, 180.0, 270.0, 0.0, 180.0];
    final x = _round2((variant * 0.618034) % 1 * tile);
    final y = _round2((variant * 0.381966 + 0.17) % 1 * tile);
    return InkAffine.translate(
      x,
      y,
    ).multiply(InkAffine.rotate(rotations[variant]));
  }

  static double _round2(double value) => (value * 100 + 0.5).floor() / 100;

  /// Applies grain [kind] variant [variant] to everything drawn in the
  /// current layer. Returns false when the tile is not decoded yet.
  static bool apply(Canvas canvas, Image tile, String kind, int variant) {
    final spec = InkTextures.grainTile(kind);
    if (spec == null) return false;
    final css = spec.cssWidth;
    final toUser = phase(
      variant,
      css,
    ).multiply(InkAffine.scale(css / tile.width, css / tile.height));
    final paint = Paint()
      ..shader = ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        toUser.storage,
        filterQuality: FilterQuality.low,
      )
      ..colorFilter = luminanceToAlpha
      ..blendMode = BlendMode.dstIn;
    canvas.drawPaint(paint);
    return true;
  }
}
