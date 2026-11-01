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

  testWidgets('squiggle-kinds in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 360,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d24,
              children: [
                Expanded(
                  child: Column(
                    spacing: Spacing.d16,
                    children: [
                      for (final kind in SquiggleKind.values)
                        Squiggle(kind: kind, seed: 'kind-${kind.name}'),
                      for (final weight in MarkWeight.values)
                        Squiggle(
                          tone: MarkPen.blue,
                          weight: weight,
                          seed: 'weight-${weight.name}',
                        ),
                    ],
                  ),
                ),
                for (final kind in [SquiggleKind.wavy, SquiggleKind.zigzag])
                  Squiggle(
                    kind: kind,
                    orientation: SquiggleOrientation.vertical,
                    tone: MarkPen.red,
                    seed: 'vertical-${kind.name}',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/squiggle-kinds.png'),
    );
  });
}
