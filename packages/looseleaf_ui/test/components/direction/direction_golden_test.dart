import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _island(TextDirection direction) => DirectionProvider(
  direction: direction,
  child: SizedBox(
    width: 320,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Progress(value: 35, seed: 'p-${direction.name}'),
        Row(
          spacing: Spacing.d8,
          children: [
            Badge(seed: 'b-${direction.name}', child: Text(direction.name)),
            KbdGroup(
              children: [
                Kbd(seed: 'k1-${direction.name}', child: const Text('Ctrl')),
                Kbd(seed: 'k2-${direction.name}', child: const Text('K')),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('direction-islands in the light theme', (tester) async {
    tester.view.physicalSize = const Size(800, 500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            spacing: Spacing.d24,
            children: [
              _island(TextDirection.ltr),
              _island(TextDirection.rtl),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/direction-islands.png'),
    );
  });
}
