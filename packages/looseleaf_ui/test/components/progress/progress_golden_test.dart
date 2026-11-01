import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _bars() => const SizedBox(
  width: 420,
  child: Column(
    spacing: Spacing.d16,
    children: [
      Progress(value: 45, size: ProgressSize.sm, seed: 'sm'),
      Progress(value: 45, seed: 'default'),
      Progress(value: 45, size: ProgressSize.lg, seed: 'lg'),
      Progress(value: 70, tone: ProgressTone.hi, seed: 'hi'),
      Progress(value: 70, tone: ProgressTone.green, seed: 'green'),
      Progress(value: 70, tone: ProgressTone.blue, seed: 'blue'),
      Progress(value: 0, seed: 'empty'),
      Progress(value: 100, seed: 'full'),
      Progress(seed: 'waiting'),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('progress-bars in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(_bars()),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/progress-bars.png'),
    );
  });
}
