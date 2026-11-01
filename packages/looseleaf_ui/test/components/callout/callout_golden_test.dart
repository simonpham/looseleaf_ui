import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _notes = [
  (ArrowDirection.left, 'check the date!'),
  (ArrowDirection.right, 'ask sam'),
  (ArrowDirection.up, 'this again?'),
  (ArrowDirection.down, 'so true'),
  (ArrowDirection.upLeft, 'nice one'),
  (ArrowDirection.upRight, 'wait, why?'),
  (ArrowDirection.downLeft, 'move this up'),
  (ArrowDirection.downRight, 'the best line'),
];

Widget _directions() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d32,
  children: [
    const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: Color(0xFF8E887F)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.d12,
              vertical: Spacing.d8,
            ),
            child: Text('the total'),
          ),
        ),
        Callout('check the date!', seed: 'default'),
      ],
    ),
    for (final row in [_notes.sublist(0, 4), _notes.sublist(4)])
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d40,
        children: [
          for (final (i, (direction, text)) in row.indexed)
            Callout(
              text,
              direction: direction,
              seed: 'd${direction.id}$i',
              curve: switch (direction) {
                ArrowDirection.downLeft => ArrowCurve.curl,
                _ => ArrowCurve.curved,
              },
            ),
        ],
      ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('callout-directions in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2200, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(goldenPanel(_directions())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/callout-directions.png'),
    );
  });
}
