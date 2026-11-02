import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Turns sketch strokes into files: an SVG document through the engine's
/// `strokesToSvg`, or PNG bytes painted the way the canvas paints them.
///
/// Mirrors `toSVG` and `toPNG` of upstream `src/components/ui/sketchpad.tsx`
/// and `svgToPngDataUrl` in `src/lib/sketch-export.ts`.
abstract final class SketchpadExport {
  /// [strokes] as a standalone SVG of [width] × [height], grown by
  /// [margin] on every side, on a paper [background], with `--ll-*`
  /// paints resolved to [colors] and grain tiles embedded as data URIs.
  static String svg(
    List<SketchStroke> strokes, {
    required double width,
    required double height,
    LooseleafColors colors = const LooseleafColors(),
    bool background = true,
    double? margin,
    String? title,
    Tier? tier,
  }) => strokesToSvg(
    strokes,
    InkExport.tileUri,
    width: width,
    height: height,
    tier: tier,
    margin: margin,
    title: title,
    background: switch (background) {
      true => InkExport.cssColor(colors.paper),
      false => null,
    },
    resolve: (name) => switch (colors.token(name.replaceFirst('--ll-', ''))) {
      final color? => InkExport.cssColor(color),
      null => null,
    },
  );

  /// [strokes] as PNG bytes of ([width] + 2 × [margin]) × ([height] +
  /// 2 × [margin]) CSS pixels at [scale], or null when encoding fails.
  static Future<Uint8List?> png(
    List<SketchStroke> strokes, {
    required double width,
    required double height,
    LooseleafThemeData theme = const LooseleafThemeData(),
    bool background = true,
    double margin = 0,
    double scale = 2,
  }) async {
    final w = width + 2 * margin, h = height + 2 * margin;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    if (background) {
      canvas.drawRect(
        Offset.zero & Size(w, h),
        Paint()..color = theme.colors.paper,
      );
    }
    canvas.translate(margin, margin);
    final context = InkPaintContext(theme: theme);
    final tier = SketchInk.tier(theme);
    for (final stroke in strokes) {
      final markup = strokeMarkup(stroke, tier: tier);
      SketchInk.paint(canvas, SketchInk.document(markup), context);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (w * scale).round().clamp(1, 1 << 14),
      (h * scale).round().clamp(1, 1 << 14),
    );
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  }

  /// [svg] as a `data:` URL.
  static String dataUrl(String svg) => svgDataUrl(svg);
}
