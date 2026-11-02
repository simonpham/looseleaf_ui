import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/fixture_frames.dart';
import '../support/render_frame.dart';

void main() {
  final out = Platform.environment['INK_RENDER_DIR'];
  testWidgets('renders fixtures to PNG', (tester) async {
    await tester.runAsync(InkTextures.instance.load);
    for (final frame in FixtureFrame.load()) {
      final layers = (Platform.environment['INK_LAYERS'] ?? 'rest')
          .split(',')
          .toSet();
      final image = renderFixture(frame, layers: layers);
      final bytes = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      File(
        '$out/${frame.name}.png',
      ).writeAsBytesSync(bytes?.buffer.asUint8List() ?? []);
    }
  }, skip: out == null);
}
