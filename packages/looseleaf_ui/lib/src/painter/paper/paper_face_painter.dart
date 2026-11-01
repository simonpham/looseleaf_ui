import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints a paper face: the stock's colour, its sheen (`--ll-paper-light`),
/// its tooth tiles at seeded offsets and a sticky note's gum veil, clipped to
/// a path.
///
/// The Flutter side of the `.ll-face` and `.ll-paper::before` backgrounds in
/// upstream `src/styles/looseleaf.css`, with the variables `faceLook`
/// (`src/lib/ink/paper/faces.ts`) sets.
abstract final class PaperFacePainter {
  /// The CSS colour of [stock]: its base token, mixed with its tint.
  static Color stockColor(ink.StockName stock, LooseleafColors colors) {
    final def = ink.stockOf(stock);
    final base = colors.token(def.base) ?? colors.paper;
    final tint = def.tint;
    if (tint == null) return base;
    final (token, share) = tint;
    return Color.lerp(base, colors.token(token) ?? base, share) ?? base;
  }

  /// Paints a face of [stock] inside [clip]; [box] is the background box the
  /// sheen spans and the tiles start from (the clip's bounds by default).
  /// [seed] offsets the tiles; [veil] false skips the gum veil.
  static void paint(
    Canvas canvas,
    Path clip, {
    required ink.StockName stock,
    required Object seed,
    required LooseleafThemeData theme,
    Rect? box,
    bool veil = true,
    InkTextures? textures,
  }) {
    final area = box ?? clip.getBounds();
    if (area.isEmpty) return;
    final def = ink.stockOf(stock);
    final colors = theme.colors;
    final color = stockColor(stock, colors);
    canvas
      ..save()
      ..clipPath(clip)
      ..drawRect(area, Paint()..color = color);
    _sheen(canvas, area, theme);
    _tooth(canvas, area, def.tooth, seed, textures ?? InkTextures.instance);
    if (def.gum && veil) {
      canvas.drawRect(
        area,
        Paint()..color = color.withValues(alpha: color.a * ink.stickyVeil),
      );
    }
    canvas.restore();
  }

  static void _sheen(Canvas canvas, Rect area, LooseleafThemeData theme) {
    final shade = theme.colors.shade;
    final half = (area.width + area.height) * math.sqrt1_2 / 2;
    final direction = const Offset(math.sqrt1_2, math.sqrt1_2) * half;
    final center = area.center;
    canvas.drawRect(
      area,
      Paint()
        ..shader = Gradient.linear(
          center - direction,
          center + direction,
          [
            const Color(0x61FFFFFF),
            const Color(0x00FFFFFF),
            shade.withValues(alpha: 0),
            shade.withValues(alpha: (0.035 * theme.shadowK).clamp(0.0, 1.0)),
          ],
          const [0, 0.42, 0.42, 1],
        ),
    );
  }

  static void _tooth(
    Canvas canvas,
    Rect area,
    ink.Tooth tooth,
    Object seed,
    InkTextures textures,
  ) {
    final tiles = ink.toothTiles[tooth] ?? const <ink.PaperTileName>[];
    final offsets = ink.tileOffsetList(seed, ink.toothTileSizes(tooth));
    for (var i = tiles.length - 1; i >= 0; i--) {
      final tile = tiles[i];
      final image = textures.paper(tile.name);
      if (image == null) continue;
      final (dx, dy) = offsets[i];
      final scale = tile.cssWidth / image.width;
      final matrix = Float64List(16)
        ..[0] = scale
        ..[5] = tile.cssHeight / image.height
        ..[10] = 1
        ..[12] = area.left + dx
        ..[13] = area.top + dy
        ..[15] = 1;
      canvas.drawRect(
        area,
        Paint()
          ..filterQuality = FilterQuality.low
          ..shader = ImageShader(
            image,
            TileMode.repeated,
            TileMode.repeated,
            matrix,
          ),
      );
    }
  }
}
