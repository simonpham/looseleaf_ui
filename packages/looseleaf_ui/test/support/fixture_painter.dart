import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import 'fixture_frames.dart';

/// Paints a fixture frame's [layers] on paper, the frame's box at the
/// center, for golden tests.
class FixturePainter extends CustomPainter {
  FixturePainter(this.frame, {this.layers = const {'rest'}})
    : document = InkDocument.parseLayers(frame.parts);

  final FixtureFrame frame;
  final Set<String> layers;
  final InkDocument document;

  @override
  void paint(Canvas canvas, Size size) {
    const theme = LooseleafThemeData();
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.colors.paper);
    canvas.translate(
      (size.width - frame.width) / 2,
      (size.height - frame.height) / 2,
    );
    final painter = InkPainter(document, InkPaintContext(theme: theme));
    canvas.saveLayer(null, Paint());
    for (final layer in InkLayers.sorted(frame.parts.keys)) {
      if (layers.contains(layer)) painter.paintLayer(canvas, layer);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(FixturePainter oldDelegate) => false;
}
