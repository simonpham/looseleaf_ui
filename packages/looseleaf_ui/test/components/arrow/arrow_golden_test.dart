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

  testWidgets('arrow-directions in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1800, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              for (final curve in ArrowCurve.values)
                Wrap(
                  spacing: Spacing.d16,
                  runSpacing: Spacing.d16,
                  children: [
                    for (final direction in ArrowDirection.values)
                      Arrow(
                        direction: direction,
                        curve: curve,
                        seed: '${curve.name}-${direction.id}',
                      ),
                  ],
                ),
              Wrap(
                spacing: Spacing.d16,
                children: [
                  for (final head in ArrowHead.values)
                    Arrow(
                      head: head,
                      tone: MarkPen.blue,
                      curve: ArrowCurve.curved,
                      seed: 'head-${head.name}',
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsetsDirectional.only(start: Spacing.d96),
                child: Arrow(
                  direction: ArrowDirection.left,
                  curve: ArrowCurve.curved,
                  tone: MarkPen.blue,
                  seed: 'label',
                  label: Text('the best line'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/arrow-directions.png'),
    );
  });
}
