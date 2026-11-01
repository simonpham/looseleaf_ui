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

  testWidgets('tally-counts in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              for (final size in TallySize.values)
                Wrap(
                  spacing: Spacing.d24,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final count in [1, 4, 5, 7, 12])
                      Tally(
                        count: count,
                        size: size,
                        seed: '${size.name}-$count',
                      ),
                  ],
                ),
              Wrap(
                spacing: Spacing.d24,
                children: [
                  for (final tone in [
                    MarkPen.red,
                    MarkPen.blue,
                    MarkPen.pencil,
                  ])
                    Tally(
                      count: 9,
                      tone: tone,
                      seed: 'tone-${tone.id}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/tally-counts.png'),
    );
  });
}
