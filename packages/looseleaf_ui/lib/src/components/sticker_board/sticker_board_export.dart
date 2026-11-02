import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sticker/sticker.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sticker board saved out: the [items], the same as pretty [json], an
/// [svg] document of the board (through the engine's `composeBoardSvg`,
/// paints resolved to the theme's colours and grain tiles embedded), its
/// size, and [png] to paint it to PNG bytes.
///
/// Mirrors `StickerBoardExport` in upstream
/// `src/components/ui/sticker-board.tsx`.
class StickerBoardExport {
  StickerBoardExport({
    required this.items,
    required this.width,
    required this.height,
    required this.size,
    this.theme = const LooseleafThemeData(),
  });

  /// The stickers, as placed.
  final List<StickerBoardItem> items;

  /// The board's size in pixels.
  final double width;
  final double height;

  /// The stickers' drawn size in pixels.
  final double size;

  /// The colours `var(--ll-…)` paints resolve to.
  final LooseleafThemeData theme;

  /// [items] as indented JSON.
  String get json => const JsonEncoder.withIndent(
    '  ',
  ).convert([for (final item in items) item.toJson()]);

  /// The board as a standalone SVG document on paper.
  late final String svg = composeBoardSvg(
    items,
    InkExport.tileUri,
    width: width,
    height: height,
    size: size,
    resolve: (svg) => svg.replaceAllMapped(
      RegExp(r'var\(--ll-([a-z0-9-]+)\)'),
      (m) => switch (theme.colors.token(m[1] ?? '')) {
        final color? => InkExport.cssColor(color),
        null => m[0] ?? '',
      },
    ),
  );

  /// The board painted at [scale] as PNG bytes, or null when encoding
  /// fails.
  Future<Uint8List?> png({double scale = 2}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    canvas.drawRect(
      Offset.zero & Size(width, height),
      Paint()..color = theme.colors.paper,
    );
    final ordered = [...wholeItems(items).indexed]
      ..sort((a, b) {
        final byZ = a.$2.z.compareTo(b.$2.z);
        if (byZ != 0) return byZ;
        return a.$1.compareTo(b.$1);
      });
    for (final (i, (_, it)) in ordered.indexed) {
      final art = StickerFaceArt(
        name: it.name,
        size: size,
        seed: it.id,
        idPrefix: 'll-x$i',
      );
      final face = art.face;
      if (face == null) continue;
      final frame = InkArtFrame.of(
        InkResult(
          svg: face.svg,
          w: face.w,
          h: face.h,
          pad: 12,
          layers: const [],
          parts: const {},
          bbox: BBox(0, 0, face.w, face.h),
        ),
      );
      canvas
        ..save()
        ..translate(it.x, it.y)
        ..rotate(it.rot * math.pi / 180)
        ..scale(it.scale)
        ..translate(
          -(face.box.x + face.box.w / 2),
          -(face.box.y + face.box.h / 2),
        );
      InkArtPainter(
        frame: frame,
        theme: theme,
        currentColor: theme.colors.ink,
      ).paint(canvas, Size(face.w, face.h));
      canvas.restore();
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * scale).round().clamp(1, 1 << 14),
      (height * scale).round().clamp(1, 1 << 14),
    );
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  }
}
