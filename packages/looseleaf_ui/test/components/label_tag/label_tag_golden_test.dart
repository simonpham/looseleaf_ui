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

  testWidgets('label-tag-shapes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1640, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: Wrap(
                spacing: Spacing.d48,
                runSpacing: Spacing.d40,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  const LabelTag(
                    seed: 'sale',
                    tiltDegrees: -3,
                    children: [
                      LabelTagTitle(Text('Sale')),
                      LabelTagDescription(Text('while stocks last')),
                      LabelTagPrice(Text('12.00')),
                    ],
                  ),
                  const LabelTag(
                    stock: StockName.paper,
                    twine: Accent.tomato,
                    eyelet: TagEyelet.steel,
                    seed: 'a',
                    tiltDegrees: 2,
                    children: [
                      LabelTagTitle(Text('Gift')),
                      LabelTagDescription(Text('for Ada')),
                    ],
                  ),
                  const LabelTag(
                    stock: StockName.stickyYellow,
                    shape: TagShape.round,
                    twine: Accent.grass,
                    seed: 'b',
                    tiltDegrees: -2,
                    children: [
                      LabelTagTitle(Text('New')),
                      LabelTagDescription(Text('this week')),
                      LabelTagPrice(Text('4.50')),
                    ],
                  ),
                  const LabelTag(
                    stock: StockName.stickyPink,
                    twine: Accent.grape,
                    eyelet: TagEyelet.none,
                    seed: 'c',
                    tiltDegrees: 3,
                    children: [
                      LabelTagTitle(Text('Hi!')),
                      LabelTagDescription(Text('a bare hole')),
                    ],
                  ),
                  const LabelTag(
                    shape: TagShape.luggage,
                    string: 60,
                    seed: 'd',
                    tiltDegrees: 1.4,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelTagTitle(Text('Ada Lovelace')),
                          LabelTagDescription(Text('Gate 7 - seat 14A')),
                        ],
                      ),
                    ],
                  ),
                  LabelTag(
                    shape: TagShape.round,
                    stock: StockName.paper,
                    twine: Accent.sky,
                    width: 112,
                    height: 112,
                    seed: 'Gifts',
                    onPressed: () {},
                    forcedStates: const {InkState.hovered, InkState.focused},
                    children: const [LabelTagTitle(Text('Gifts'))],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/label-tag-shapes.png'),
    );
  });
}
