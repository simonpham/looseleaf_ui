import 'dart:ui' as ui;

import 'package:looseleaf_ui/looseleaf_ui.dart';

import 'fixture_frames.dart';

/// Paints every layer of [frame] whose name is in [layers] onto a paper
/// background at [scale], returning the picture as an image.
ui.Image renderFixture(
  FixtureFrame frame, {
  Set<String> layers = const {'rest'},
  double scale = 2,
  LooseleafThemeData theme = const LooseleafThemeData(),
}) {
  final document = InkDocument.parseLayers(frame.parts);
  final margin = frame.pad + 8;
  final width = frame.width + 2 * margin;
  final height = frame.height + 2 * margin;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(scale);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width, height),
    ui.Paint()..color = theme.colors.paper,
  );
  canvas.translate(margin, margin);
  final painter = InkPainter(document, InkPaintContext(theme: theme));
  canvas.saveLayer(null, ui.Paint());
  for (final layer in InkLayers.sorted(frame.parts.keys)) {
    if (layers.contains(layer)) painter.paintLayer(canvas, layer);
  }
  canvas.restore();
  final picture = recorder.endRecording();
  return picture.toImageSync((width * scale).ceil(), (height * scale).ceil());
}
