import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/markup.dart';
import 'package:looseleaf_ui/src/painter/render/ink_paint_context.dart';

/// Builds the shaders `url(#id)` paints refer to: gradients and patterns.
class InkShaders {
  InkShaders(this.document, this.context, this.paintChildren);

  final InkDocument document;
  final InkPaintContext context;

  /// Paints pattern content into a tile canvas.
  final void Function(Canvas canvas, List<InkNode> children) paintChildren;

  /// The shader for [def] painted on a shape whose box is [box], at device
  /// scale [scale]; null when it cannot be built.
  Shader? shader(InkDef def, Rect box, double scale) => switch (def) {
    InkGradientDef() => _gradient(def, box),
    InkPatternDef() => _pattern(def, scale),
    _ => null,
  };

  Shader? _gradient(InkGradientDef def, Rect box) {
    if (def.stops.isEmpty) return null;
    Offset map(Offset point) => switch (def.userSpace) {
      true => point,
      false => Offset(
        box.left + point.dx * box.width,
        box.top + point.dy * box.height,
      ),
    };
    final colors = [for (final stop in def.stops) _stopColor(stop)];
    final stops = [for (final stop in def.stops) stop.offset];
    final matrix = switch ((def.userSpace, def.transform)) {
      (true, final transform?) => transform.storage,
      _ => null,
    };
    if (def.radial) {
      final radius = switch (def.userSpace) {
        true => def.radius,
        false => def.radius * (box.width + box.height) / 2,
      };
      return Gradient.radial(
        map(def.from),
        radius,
        colors,
        stops,
        TileMode.clamp,
        matrix,
      );
    }
    return Gradient.linear(
      map(def.from),
      map(def.to),
      colors,
      stops,
      TileMode.clamp,
      matrix,
    );
  }

  Color _stopColor(InkStop stop) {
    final color = resolveColor(stop.color) ?? const Color(0x00000000);
    final opacity = stop.opacity.resolve(context.scalar).clamp(0.0, 1.0);
    return color.withValues(alpha: color.a * opacity);
  }

  /// The color of a non-url paint, or null for `none` and unknown tokens.
  Color? resolveColor(InkPaint paint) => switch (paint) {
    InkNoPaint() || InkUrlPaint() => null,
    InkCurrentColor() => context.currentColor,
    InkColorPaint(:final color) => color,
    InkTokenPaint(:final token, :final fallback) =>
      context.colors.token(token) ??
          switch (fallback) {
            null => null,
            final other => resolveColor(other),
          },
  };

  Shader? _pattern(InkPatternDef def, double scale) {
    final tile = def.tile;
    if (tile.width <= 0 || tile.height <= 0) return null;
    final pixelsWide = (tile.width * scale).ceil().clamp(1, 2048);
    final pixelsHigh = (tile.height * scale).ceil().clamp(1, 2048);
    final key = (def, context.paintKey, pixelsWide, pixelsHigh);
    final image = document.patternTiles[key] ??= _renderTile(
      def,
      pixelsWide,
      pixelsHigh,
    );
    final toUser = (def.transform ?? InkAffine.identity)
        .multiply(InkAffine.translate(tile.left, tile.top))
        .multiply(
          InkAffine.scale(tile.width / pixelsWide, tile.height / pixelsHigh),
        );
    return ImageShader(
      image,
      TileMode.repeated,
      TileMode.repeated,
      toUser.storage,
      filterQuality: FilterQuality.low,
    );
  }

  Image _renderTile(InkPatternDef def, int pixelsWide, int pixelsHigh) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelsWide / def.tile.width, pixelsHigh / def.tile.height);
    paintChildren(canvas, def.children);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(pixelsWide, pixelsHigh);
    picture.dispose();
    return image;
  }
}
