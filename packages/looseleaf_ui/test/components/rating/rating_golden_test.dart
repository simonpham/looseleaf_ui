import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(List<Widget> children) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d32,
  children: children,
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('rating-glyphs in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              const Rating(initialValue: 3, seed: 'default'),
              _row(const [
                Rating(initialValue: 3.5, allowHalf: true, seed: 'half'),
                Rating(
                  icon: RatingIcon.heart,
                  initialValue: 4,
                  seed: 'heart',
                ),
                Rating(icon: RatingIcon.sun, initialValue: 2, seed: 'sun'),
              ]),
              _row(const [
                Rating(size: RatingSize.sm, initialValue: 4, seed: 'sm'),
                Rating(size: RatingSize.lg, initialValue: 4, seed: 'lg'),
                Rating(
                  max: 10,
                  size: RatingSize.sm,
                  initialValue: 7,
                  seed: 'ten',
                ),
              ]),
              _row(const [
                Rating(initialValue: 3, disabled: true, seed: 'disabled'),
                Rating(initialValue: 2, invalid: true, seed: 'invalid'),
                Rating(
                  initialValue: 4.5,
                  allowHalf: true,
                  readOnly: true,
                  seed: 'read',
                ),
              ]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/rating-glyphs.png'),
    );
  });
}
