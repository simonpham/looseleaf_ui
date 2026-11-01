import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _shapes() => const SizedBox(
  width: 420,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      Row(
        spacing: Spacing.d16,
        children: [
          Skeleton(width: 48, height: 48, circle: true, seed: 'avatar'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Skeleton(width: 250, height: 16, seed: 'l1'),
              Skeleton(width: 200, height: 16, seed: 'l2'),
            ],
          ),
        ],
      ),
      Skeleton(height: 144, seed: 'picture'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Skeleton(height: 12, seed: 't1'),
          Skeleton(width: 386, height: 12, seed: 't2'),
          Skeleton(width: 269, height: 12, seed: 't3'),
        ],
      ),
      Row(
        spacing: Spacing.d12,
        children: [
          Skeleton(width: 96, height: 36, seed: 'b1'),
          Skeleton(width: 80, height: 36, seed: 'b2'),
          Skeleton(width: 36, height: 36, circle: true, seed: 'b3'),
        ],
      ),
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

  testWidgets('skeleton-shapes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(_shapes()),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/skeleton-shapes.png'),
    );
  });
}
