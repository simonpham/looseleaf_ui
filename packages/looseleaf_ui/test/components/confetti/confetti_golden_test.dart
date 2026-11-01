import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, options) in [
    ('confetti-cone', const ConfettiOptions(seed: 3)),
    (
      'confetti-ring',
      const ConfettiOptions(
        seed: 5,
        spread: 360,
        velocity: 700,
        count: 90,
        shapes: [ConfettiKind.dot, ConfettiKind.strip],
      ),
    ),
  ]) {
    testWidgets('$name mid-flight', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final controller = ConfettiController();
      await tester.pumpWidget(
        componentHost(
          goldenPanel(
            SizedBox(
              width: 440,
              height: 320,
              child: Confetti(controller: controller, options: options),
            ),
          ),
        ),
      );
      controller.burst();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/$name.png'),
      );
      await tester.pumpAndSettle();
    });
  }
}
