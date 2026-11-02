import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';

/// What a drawing saved as a standalone SVG needs: grain tiles embedded as
/// data URIs and paints written as CSS colours. Shared by the sketchpad,
/// signature pad and sticker board exports.
abstract final class InkExport {
  /// A grain or paper tile as a base64 PNG data URI, empty when unknown.
  static String tileUri(String name) =>
      switch (InkTextures.grainTile(name) ?? InkTextures.paperTile(name)) {
        final tile? => 'data:image/png;base64,${tile.base64}',
        null => '',
      };

  /// [color] as CSS: `#rrggbb`, or `rgba(…)` when translucent.
  static String cssColor(Color color) {
    int channel(double v) => (v * 255).round().clamp(0, 255);
    final r = channel(color.r), g = channel(color.g), b = channel(color.b);
    if (color.a >= 1) {
      final hex = [
        r,
        g,
        b,
      ].map((v) => v.toRadixString(16).padLeft(2, '0')).join();
      return '#$hex';
    }
    final alpha = JsMath.numberToString((color.a * 1000).round() / 1000);
    return 'rgba($r, $g, $b, $alpha)';
  }
}
