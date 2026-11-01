import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints a sheet's CSS `box-shadow`: warm umber layers around a box, never
/// under it, scaled by the theme's `--ll-shadow-k`.
///
/// The Flutter side of `--ll-shadow-<kind>` and `farShadow` in upstream
/// `src/lib/ink/paper/shadows.ts`.
abstract final class PaperShadowPainter {
  /// The layers of [kind]; without [all], only the soft ones (blur over
  /// 2 px), as a face casts them beside its drawn contact shadow.
  static List<ink.ShadowLayer> layersOf(
    ink.SheetShadowKind kind, {
    bool all = true,
  }) => [
    for (final layer in ink.shadowLayers[kind] ?? const <ink.ShadowLayer>[])
      if (all || layer.blur > 2) layer,
  ];

  /// Paints [layers] around [box] (offset `dy`, blurred by `blur`, grown by
  /// `spread`), clipped to outside [box] like CSS.
  static void paint(
    Canvas canvas,
    RRect box,
    List<ink.ShadowLayer> layers, {
    required LooseleafThemeData theme,
  }) {
    if (layers.isEmpty || theme.shadowK <= 0 || box.isEmpty) return;
    final reach = layers.fold<double>(
      0,
      (most, layer) => most + layer.dy.abs() + layer.blur * 2 + layer.spread,
    );
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(box.outerRect.inflate(reach + 8))
      ..addRRect(box);
    canvas
      ..save()
      ..clipPath(outside);
    for (final layer in layers) {
      final alpha = (layer.a * theme.shadowK).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = theme.colors.shade.withValues(alpha: alpha);
      if (layer.blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur / 2);
      }
      canvas.drawRRect(
        _grow(box, layer.spread).shift(Offset(0, layer.dy)),
        paint,
      );
    }
    canvas.restore();
  }

  static RRect _grow(RRect box, double by) {
    double grown(double r) => switch (r > 0) {
      true => (r + by).clamp(0.0, double.infinity),
      false => 0,
    };
    Radius radius(Radius r) => Radius.elliptical(grown(r.x), grown(r.y));
    return RRect.fromRectAndCorners(
      box.outerRect.inflate(by),
      topLeft: radius(box.tlRadius),
      topRight: radius(box.trRadius),
      bottomRight: radius(box.brRadius),
      bottomLeft: radius(box.blRadius),
    );
  }
}
