import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/painter/painter.dart';

/// One drawing of art (an icon, doodle, sticker, mascot or stamp), parsed
/// once: its document, its viewBox size and the pad it may reach past it.
class InkArtFrame {
  const InkArtFrame({
    required this.document,
    required this.width,
    required this.height,
    required this.pad,
  });

  /// Parses an engine [result], keeping its layers in drawing order.
  factory InkArtFrame.of(ink.InkResult result) => InkArtFrame(
    document: InkDocument.parseLayers({
      for (final layer in result.layers)
        if (result.parts[layer] case final part? when part.isNotEmpty)
          layer.name: part,
    }),
    width: result.w,
    height: result.h,
    pad: result.pad,
  );

  final InkDocument document;

  /// The viewBox width (`0 0 w h`).
  final double width;

  /// The viewBox height.
  final double height;

  /// How far the drawing reaches past its viewBox (`overflow: visible`).
  final double pad;
}
