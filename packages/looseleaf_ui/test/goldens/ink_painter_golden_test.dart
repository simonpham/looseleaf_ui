import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/fixture_frames.dart';
import '../support/fixture_painter.dart';

void main() {
  const goldens = {
    'button-default': {'rest'},
    'button-outline': {'rest', 'hover'},
    'checkbox': {'rest', 'checked'},
    'switch': {'rest', 'checked'},
    'separator-tape': {'rest'},
    'chart-pie': {'rest'},
    'doodle-sun': {'rest'},
    'sticker-done': {'rest'},
    'sticker-peel-sale': {'rest'},
    'seal-wax': {'rest'},
  };

  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
      InkTextures.instance.load,
    );
  });

  for (final MapEntry(key: name, value: layers) in goldens.entries) {
    testWidgets('$name in the light theme', (tester) async {
      final frame = FixtureFrame.named(name);
      await tester.runAsync(InkTextures.instance.load);
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(
                frame.width + 2 * frame.pad + 16,
                frame.height + 2 * frame.pad + 16,
              ),
              painter: FixturePainter(frame, layers: layers),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
