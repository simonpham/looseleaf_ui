import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _boxes(BuildContext context, int frame, String Function(String) seed) =>
    Wrap(
      spacing: Spacing.d16,
      children: [
        Checkbox(value: true, size: Spacing.d28, seed: seed('tick')),
        Button(seed: seed('button'), child: const Text('Boiling')),
      ],
    );

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('boil-frames in the light theme', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          const SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Text('Frame 0'),
                Boil(active: false, builder: _boxes),
                Text('Frame 1'),
                Boil(builder: _boxes),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/boil-frames.png'),
    );
  });
}
