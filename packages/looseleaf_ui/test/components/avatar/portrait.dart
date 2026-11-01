import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A gradient portrait like the docs examples', as PNG bytes.
Future<MemoryImage> portrait(Color from, Color to) async {
  final recorder = ui.PictureRecorder();
  const side = 64.0;
  Canvas(recorder)
    ..drawRect(
      const Rect.fromLTWH(0, 0, side, side),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(side, side), [
          from,
          to,
        ]),
    )
    ..drawCircle(
      const Offset(32, 26),
      11,
      Paint()..color = const Color(0x8C3A2F28),
    )
    ..drawOval(
      Rect.fromCenter(center: const Offset(32, 62), width: 46, height: 38),
      Paint()..color = const Color(0x803A2F28),
    );
  final image = await recorder.endRecording().toImage(64, 64);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(bytes?.buffer.asUint8List() ?? Uint8List(0));
}
